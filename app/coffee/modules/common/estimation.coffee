###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/common/estimation.coffee
###

taiga = @.taiga
groupBy = @.taiga.groupBy

module = angular.module("taigaCommon")

#############################################################################
## User story estimation directive (for Lightboxes)
#############################################################################

LbUsEstimationDirective = ($tgEstimationsService, $rootScope, $repo, $confirm, $template, $compile) ->
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
                estimationProcess.onSelectedPointForRole = (roleId, pointId) ->
                    $scope.$apply ->
                        $model.$setViewValue(us)


                estimationProcess.render = () ->
                    ctx = {
                        totalPoints: @calculateTotalPoints()
                        roles: @calculateRoles()
                        editable: @isEditable
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

module.directive("tgLbUsEstimation", ["$tgEstimationsService", "$rootScope", "$tgRepo", "$tgConfirm", "$tgTemplate", "$compile", LbUsEstimationDirective])


#############################################################################
## User story estimation directive
#############################################################################

UsEstimationDirective = ($tgEstimationsService, $rootScope, $repo, $confirm, $qqueue, $template, $compile) ->
    # Display the points of a US and you can edit it.
    #
    # Example:
    #     tg-us-estimation-progress-bar(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.project object

    link = ($scope, $el, $attrs, $model) ->
        $scope.$watch $attrs.ngModel, (us) ->
            if us
                estimationProcess = $tgEstimationsService.create($el, us, $scope.project)
                estimationProcess.onSelectedPointForRole = (roleId, pointId) ->
                    @save(roleId, pointId).then ->
                        $rootScope.$broadcast("object:updated")

                estimationProcess.render = () ->
                    ctx = {
                        totalPoints: @calculateTotalPoints()
                        roles: @calculateRoles()
                        editable: @isEditable
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

module.directive("tgUsEstimation", ["$tgEstimationsService", "$rootScope", "$tgRepo", "$tgConfirm", "$tgQqueue", "$tgTemplate", "$compile"
                                    UsEstimationDirective])


#############################################################################
## Estimations service
#############################################################################

EstimationsService = ($template, $qqueue, $repo, $confirm, $q) ->
    pointsTemplate = $template.get("common/estimation/us-estimation-points.html", true)

    class EstimationProcess
        constructor: (@$el, @us, @project) ->
            @isEditable = @project.my_permissions.indexOf("modify_us") != -1
            @roles = @project.roles
            @points = @project.points
            @pointsById = groupBy(@points, (x) -> x.id)
            @onSelectedPointForRole =  (roleId, pointId) ->
            @render = () ->

        save: (roleId, pointId) ->
            deferred = $q.defer()
            $qqueue.add () =>
                onSuccess = =>
                    deferred.resolve()
                    $confirm.notify("success")

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
                return "0"

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
                @us.points = points
                @render()
                @onSelectedPointForRole(roleId, pointId)

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

module.factory("$tgEstimationsService", ["$tgTemplate", "$tgQqueue",  "$tgRepo", "$tgConfirm", "$q", EstimationsService])
