###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
groupBy = @.taiga.groupBy

module = angular.module("taigaCommon")

#############################################################################
## User story estimation directive (for Lightboxes)
#############################################################################

LbUsEstimationDirective = ($tgEstimationsService, $rootScope, $repo, $template, $compile) ->
    # Display the points of a US and you can edit it.
    #
    # Example:
    #     tg-lb-us-estimation-progress-bar(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.project object

    link = ($scope, $el, $attrs, $model) ->
        $scope.$watch $attrs.ngModel, (us) ->
            if us
                estimationProcess = $tgEstimationsService.create($el, us, $scope.project)
                estimationProcess.onSelectedPointForRole = (roleId, pointId, points) ->
                    us.points = points
                    estimationProcess.render()

                    $scope.$apply ->
                        $model.$setViewValue(us)

                estimationProcess.render = () ->
                    ctx = {
                        totalPoints: @calculateTotalPoints()
                        roles: @calculateRoles()
                        editable: @isEditable
                        loading: false
                    }
                    mainTemplate = "common/estimation/us-estimation-points-per-role.html"
                    template = $template.get(mainTemplate, true)
                    html = template(ctx)
                    html = $compile(html)($scope)
                    @$el.html(html)

                estimationProcess.render()
        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgLbUsEstimation", ["$tgEstimationsService", "$rootScope", "$tgRepo", "$tgTemplate",
                                      "$compile", LbUsEstimationDirective])


#############################################################################
## User story estimation directive
#############################################################################

UsEstimationDirective = ($tgEstimationsService, $rootScope, $repo, $template, $compile, $modelTransform, $confirm) ->
    # Display the points of a US and you can edit it.
    #
    # Example:
    #     tg-us-estimation-progress-bar(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.project object

    link = ($scope, $el, $attrs, $model) ->
        save = (points) ->
            transform = $modelTransform.save (us) =>
                us.points = points

                return us

            onError = =>
                $confirm.notify("error")

            return transform.then(null, onError)

        $scope.$watchCollection () ->
            return $model.$modelValue && $model.$modelValue.points
        , () ->
            us = $model.$modelValue
            if us
                estimationProcess = $tgEstimationsService.create($el, us, $scope.project)
                estimationProcess.onSelectedPointForRole = (roleId, pointId, points) ->
                    estimationProcess.loading = roleId
                    estimationProcess.render()
                    save(points).then () ->
                        estimationProcess.loading = false
                        $rootScope.$broadcast("object:updated")
                        estimationProcess.render()

                estimationProcess.render = () ->
                    ctx = {
                        totalPoints: @calculateTotalPoints()
                        roles: @calculateRoles()
                        editable: @isEditable
                        loading: estimationProcess.loading
                    }
                    mainTemplate = "common/estimation/us-estimation-points-per-role.html"
                    template = $template.get(mainTemplate, true)
                    html = template(ctx)
                    html = $compile(html)($scope)
                    @$el.html(html)

                estimationProcess.render()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsEstimation", ["$tgEstimationsService", "$rootScope", "$tgRepo",
                                    "$tgTemplate", "$compile", "$tgQueueModelTransformation",
                                    "$tgConfirm", UsEstimationDirective])


#############################################################################
## Estimations service
#############################################################################

EstimationsService = ($template, $repo, $confirm, $q, $qqueue) ->
    pointsTemplate = $template.get("common/estimation/us-estimation-points.html", true)

    class EstimationProcess
        constructor: (@$el, @us, @project) ->
            @isEditable = @project.my_permissions.indexOf("modify_us") != -1
            @roles = @project.roles
            @points = @project.points
            @loading = false
            @pointsById = groupBy(@points, (x) -> x.id)
            @onSelectedPointForRole =  (roleId, pointId) ->
            @render = () ->

        save: (roleId, pointId) ->
            deferred = $q.defer()
            $qqueue.add () =>
                onSuccess = =>
                    deferred.resolve()
                    @render()

                onError = =>
                    $confirm.notify("error")
                    @us.revert()
                    @render()
                    deferred.reject()

                $repo.save(@us).then(onSuccess, onError)

            return deferred.promise

        calculateTotalPoints: () ->
            values = _.map(@us.points, (v, k) => @pointsById[v]?.value)

            if values.length == 0
                return "?"

            notNullValues = _.filter(values, (v) -> v?)
            if notNullValues.length == 0
                return "?"

            return _.reduce(notNullValues, (acc, num) -> acc + num)

        calculateRoles: () ->
            computableRoles = _.filter(@project.roles, "computable")
            roles = _.map computableRoles, (role) =>
                pointId = @us.points[role.id]
                pointObj = @pointsById[pointId]
                role = _.clone(role, true)
                role.points = if pointObj? and pointObj.name? then pointObj.name else "?"
                return role

            return roles

        bindClickEvents: =>
            @$el.on "click", ".total.clickable", (event) =>
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                roleId = target.data("role-id")
                @renderPointsSelector(roleId, target)
                target.siblings().removeClass('active')
                target.addClass('active')

            @$el.on "click", ".point", (event) =>
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                roleId = target.data("role-id")
                pointId = target.data("point-id")
                @$el.find(".popover").popover().close()

                points = _.clone(@us.points, true)
                points[roleId] = pointId

                @onSelectedPointForRole(roleId, pointId, points)

        renderPointsSelector: (roleId, target) ->
            points = _.map @points, (point) =>
                point = _.clone(point, true)
                point.selected = if @us.points[roleId] == point.id then false else true
                return point

            maxPointLength = 5
            horizontalList =  _.some points, (point) => point.name.length > maxPointLength

            html = pointsTemplate({"points": points, roleId: roleId, horizontal: horizontalList})
            # Remove any previous state
            @$el.find(".popover").popover().close()
            @$el.find(".pop-points-open").remove()
            # Render into DOM and show the new created element
            if target?
                @$el.find(target).append(html)
            else
                @$el.append(html)

            @$el.find(".pop-points-open").popover().open ->
                $(this)
                    .removeClass("active")
                    .closest("li").removeClass("active")

            @$el.find(".pop-points-open").show()

            pop = @$el.find(".pop-points-open")
            if pop.offset().top + pop.height() > document.body.clientHeight
                pop.addClass('pop-bottom')

    create = ($el, us, project) ->
        $el.unbind("click")

        estimationProcess = new EstimationProcess($el, us, project)

        if estimationProcess.isEditable
            estimationProcess.bindClickEvents()

        return estimationProcess

    return {
        create: create
    }

module.factory("$tgEstimationsService", ["$tgTemplate", "$tgRepo", "$tgConfirm",
                                         "$q", "$tgQqueue", EstimationsService])
