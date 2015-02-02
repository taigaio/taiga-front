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

module = angular.module("taigaCommon")

#############################################################################
## User story estimation directive (for Lightboxes)
#############################################################################

LbUsEstimationDirective = ($rootScope, $repo, $confirm, $template) ->
    # Display the points of a US and you can edit it.
    #
    # Example:
    #     tg-us-estimation-progress-bar(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.project object

    mainTemplate = $template.get("common/estimation/lb-us-estimation-points-per-role.html", true)
    pointsTemplate = $template.get("common/estimation/lb-us-estimation-points.html", true)

    link = ($scope, $el, $attrs, $model) ->
        render = (points) ->
            totalPoints = calculateTotalPoints(points) or 0
            computableRoles = _.filter($scope.project.roles, "computable")

            roles = _.map computableRoles, (role) ->
                pointId = points[role.id]
                pointObj = $scope.pointsById[pointId]

                role = _.clone(role, true)
                role.points = if pointObj? and pointObj.name? then pointObj.name else "?"
                return role

            ctx = {
                totalPoints: totalPoints
                roles: roles
            }
            html = mainTemplate(ctx)
            $el.html(html)

        renderPoints = (target, usPoints, roleId) ->
            points = _.map $scope.project.points, (point) ->
                point = _.clone(point, true)
                point.selected = if usPoints[roleId] == point.id then false else true
                return point

            html = pointsTemplate({"points": points, roleId: roleId})

            # Remove any prevous state
            $el.find(".popover").popover().close()
            $el.find(".pop-points-open").remove()

            # If not showing role selection let's move to the left
            if not $el.find(".pop-role:visible").css("left")?
                $el.find(".pop-points-open").css("left", "110px")

            $el.find(".pop-points-open").remove()

            # Render into DOM and show the new created element
            $el.find(target).append(html)

            $el.find(".pop-points-open").popover().open(-> $(this).removeClass("active"))
            $el.find(".pop-points-open").show()

        calculateTotalPoints = (points) ->
            values = _.map(points, (v, k) -> $scope.pointsById[v]?.value or 0)
            if values.length == 0
                return "0"
            return _.reduce(values, (acc, num) -> acc + num)

        $el.on "click", ".total.clickable", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")

            points = $model.$modelValue
            renderPoints(target, points, roleId)

            target.siblings().removeClass('active')
            target.addClass('active')

        $el.on "click", ".point", (event) ->
            event.preventDefault()
            event.stopPropagation()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")
            pointId = target.data("point-id")

            $el.find(".popover").popover().close()

            points = _.clone($model.$modelValue, true)
            points[roleId] = pointId

            $scope.$apply ->
                $model.$setViewValue(points)

        $scope.$watch $attrs.ngModel, (points) ->
            render(points) if points

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgLbUsEstimation", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgTemplate", LbUsEstimationDirective])


#############################################################################
## User story estimation directive
#############################################################################

UsEstimationDirective = ($rootScope, $repo, $confirm, $qqueue, $template) ->
    # Display the points of a US and you can edit it.
    #
    # Example:
    #     tg-us-estimation-progress-bar(ng-model="us")
    #
    # Requirements:
    #   - Us object (ng-model)
    #   - scope.project object

    mainTemplate = $template.get("common/estimation/us-estimation-points-per-role.html", true)
    pointsTemplate = $template.get("common/estimation/us-estimation-points.html", true)

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_us") != -1

        render = (us) ->
            totalPoints = calculateTotalPoints(us.points) or "?"
            computableRoles = _.filter($scope.project.roles, "computable")

            roles = _.map computableRoles, (role) ->
                pointId = us.points[role.id]
                pointObj = $scope.pointsById[pointId]

                role = _.clone(role, true)
                role.points = if pointObj? and pointObj.name? then pointObj.name else "?"
                return role

            ctx = {
                totalPoints: totalPoints
                roles: roles
                editable: isEditable()
            }
            html = mainTemplate(ctx)
            $el.html(html)

        renderPoints = (target, us, roleId) ->
            points = _.map $scope.project.points, (point) ->
                point = _.clone(point, true)
                point.selected = if us.points[roleId] == point.id then false else true
                return point

            html = pointsTemplate({"points": points, roleId: roleId})

            # Remove any prevous state
            $el.find(".popover").popover().close()
            $el.find(".pop-points-open").remove()

            # If not showing role selection let's move to the left
            if not $el.find(".pop-role:visible").css("left")?
                $el.find(".pop-points-open").css("left", "110px")

            $el.find(".pop-points-open").remove()

            # Render into DOM and show the new created element
            $el.find(target).append(html)

            $el.find(".pop-points-open").popover().open ->
                $(this)
                    .removeClass("active")
                    .closest("li").removeClass("active")


            $el.find(".pop-points-open").show()

        calculateTotalPoints = (points) ->
            values = _.map(points, (v, k) -> $scope.pointsById[v]?.value)
            if values.length == 0
                return "0"

            notNullValues = _.filter(values, (v) -> v?)
            if notNullValues.length == 0
                return "?"

            return _.reduce(notNullValues, (acc, num) -> acc + num)

        save = $qqueue.bindAdd (roleId, pointId) =>
            $el.find(".popover").popover().close()

            points = _.clone($model.$modelValue.points, true)
            points[roleId] = pointId

            us = $model.$modelValue.clone()
            us.points = points
            $model.$setViewValue(us)

            onSuccess = ->
                $confirm.notify("success")
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                us.revert()
                $model.$setViewValue(us)

            $repo.save(us).then(onSuccess, onError)

        $el.on "click", ".total.clickable", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")

            us = $model.$modelValue
            renderPoints(target, us, roleId)

            target.siblings().removeClass('active')
            target.addClass('active')

        $el.on "click", ".point", (event) ->
            event.preventDefault()
            event.stopPropagation()
            return if not isEditable()

            target = angular.element(event.currentTarget)
            roleId = target.data("role-id")
            pointId = target.data("point-id")

            save(roleId, pointId)

        $scope.$watch $attrs.ngModel, (us) ->
            render(us) if us

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgUsEstimation", ["$rootScope", "$tgRepo", "$tgConfirm", "$tgQqueue", "$tgTemplate",
                                    UsEstimationDirective])
