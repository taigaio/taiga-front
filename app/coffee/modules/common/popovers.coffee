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
# File: modules/common/popovers.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

module = angular.module("taigaCommon")

#############################################################################
## UserStory status Directive (popover for change status)
#############################################################################

# FIXME: change to less generic name.

UsStatusDirective = ($repo) ->
    ###
    Print the status of a US and a popover to change it.
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
    </ul>""")

    updateUsStatus = ($el, us, usStatusById) ->
        usStatusDomParent = $el.find(".us-status")
        usStatusDom = $el.find(".us-status .us-status-bind")
        usStatusDom.text(usStatusById[us.status].name)
        usStatusDomParent.css('color', usStatusById[us.status].color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        us = $scope.$eval($attrs.tgUsStatus)

        $el.on "click", ".us-status", (event) ->
            event.preventDefault()
            event.stopPropagation()
            $(".popover").hide()
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

        taiga.bindOnce $scope, "project", (project) ->
            $el.append(selectionTemplate({ 'statuses':  project.us_statuses }))
            updateUsStatus($el, us, $scope.usStatusById)

            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_us") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgUsStatus", ["$tgRepo", UsStatusDirective])
