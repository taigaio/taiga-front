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
# File: modules/common/directives.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

DateRangeDirective = ->
    renderRange = ($el, first, second) ->
        initDate = moment(first).format("YYYY/MM/DD")
        endDate = moment(second).format("YYYY/MM/DD")
        $el.html("#{initDate}-#{endDate}")

    link = ($scope, $el, $attrs) ->
        [first, second] = $attrs.tgDateRange.split(",")

        bindOnce $scope, first, (valFirst) ->
            bindOnce $scope, second, (valSecond) ->
                renderRange($el, valFirst, valSecond)

    return {link:link}


SprintProgressBarDirective = ->
    renderProgress = ($el, percentage, visual_percentage) ->
        if $el.is(".current-progress")
            $el.css("width", "#{percentage}%")
        else
            $el.find(".current-progress").css("width", "#{visual_percentage}%")
            $el.find(".number").html("#{percentage} %")

    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgSprintProgressbar, (sprint) ->
            closedPoints = sprint.closed_points
            totalPoints = sprint.total_points
            percentage = Math.round(100 * (closedPoints/totalPoints))
            visual_percentage = Math.round(98 * (closedPoints/totalPoints)) #Visual hack for .current-progress bar
            renderProgress($el, percentage, visual_percentage)

    return {link: link}


UsStatusDisplay = ->
    ###
    Show the name of a US status by id.
    It need usStatusList in the $scope.

    Example:
        <span tg-us-status-display="us.status"></span>

    ###
    link = ($scope, $el, $attrs) ->
       $scope.$watch $attrs.tgUsStatusDisplay, (status_id) ->
           if status_id is undefined
               return

           status_name = $scope.usStatusList[status_id].name
           $el.html(status_name)

    return {link:link}


module = angular.module("taigaCommon")
module.directive("tgDateRange", DateRangeDirective)
module.directive("tgSprintProgressbar", SprintProgressBarDirective)
module.directive("tgUsStatusDisplay", UsStatusDisplay)
