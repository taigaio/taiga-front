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


DateSelectorDirective =->
    link = ($scope, $el, $attrs, $model) ->
        picker = new Pikaday({field: $el[0]})

    return {
        link: link
        require: "ngModel"
    }


#############################################################################
## User story status directive
#############################################################################

UsStatusDirective = ($repo) ->
    ### Print the status of a US and a popover to change it.
        - tg-us-status: The user story
        - on-update: Method call after US is updated

    Example:

        div.status(tg-us-status="us" on-update="ctrl.loadSprintState()")
            a.us-status(href="", title="Status Name")

    NOTE: This directive need 'usStatusById' and 'project'.
    ###
    selectionTemplate = _.template("""
      <ul class="popover pop-status">
          <% _.forEach(statuses, function(status) { %>
          <li>
              <a href="" class="status" title="<%- status.name %>" data-status-id="<%- status.id %>">
                  <%- status.name %>
              </a>
          </li>
          <% }); %>
      </ul>
    """)

    updateUsStatus = ($el, us, usStatusById) ->
        usStatusDom = $el.find(".us-status")
        usStatusDom.text(usStatusById[us.status].name)
        usStatusDom.css('color', usStatusById[us.status].color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        us = $scope.$eval($attrs.tgUsStatus)

        taiga.bindOnce $scope, "project", (project) ->
            $el.append(selectionTemplate({ 'statuses':  project.us_statuses }))
            updateUsStatus($el, us, $scope.usStatusById)

        $el.on "click", ".us-status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $el.find(".pop-status").show()

            body = angular.element("body")
            body.one "click", (event) ->
                $el.find(".popover").hide()

        $el.on "click", ".status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            us.status = target.data("status-id")
            $el.find(".pop-status").hide()
            updateUsStatus($el, us, $scope.usStatusById)

            $scope.$apply () ->
                $repo.save(us).then ->
                    $scope.$eval($attrs.onUpdate)

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}


module = angular.module("taigaCommon")
module.directive("tgDateRange", DateRangeDirective)
module.directive("tgSprintProgressbar", SprintProgressBarDirective)
module.directive("tgDateSelector", DateSelectorDirective)
module.directive("tgUsStatus", ["$tgRepo", UsStatusDirective])
