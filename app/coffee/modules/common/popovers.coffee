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
debounce = @.taiga.debounce

module = angular.module("taigaCommon")

#############################################################################
## UserStory status Directive (popover for change status)
#############################################################################

UsStatusDirective = ($repo, popoverService) ->
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

        if usStatusById[us.status]
            usStatusDom.text(usStatusById[us.status].name)
            usStatusDomParent.prop("title", usStatusById[us.status].name)
            usStatusDomParent.css('color', usStatusById[us.status].color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        us = $scope.$eval($attrs.tgUsStatus)

        $el.on "click", ".us-status", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-status").popover().open()

            # pop = $el.find(".pop-status")
            # popoverService.open(pop)

        $el.on "click", ".status", debounce 2000, (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            us.status = target.data("status-id")
            $el.find(".pop-status").popover().close()
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

#############################################################################
## Related Task Status Directive
#############################################################################

RelatedTaskStatusDirective = ($repo, popoverService) ->
    ###
    Print the status of a related task and a popover to change it.
    - tg-related-task-status: The related task
    - on-update: Method call after US is updated

    Example:

      div.status(tg-related-task-status="task" on-update="ctrl.loadSprintState()")
        a.task-status(href="", title="Status Name")

    NOTE: This directive need 'taskStatusById' and 'project'.
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

    updateTaskStatus = ($el, task, taskStatusById) ->
        taskStatusDomParent = $el.find(".us-status")
        taskStatusDom = $el.find(".task-status .task-status-bind")

        if taskStatusById[task.status]
            taskStatusDom.text(taskStatusById[task.status].name)
            taskStatusDomParent.css('color', taskStatusById[task.status].color)

    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()
        task = $scope.$eval($attrs.tgRelatedTaskStatus)
        notAutoSave = $scope.$eval($attrs.notAutoSave)
        autoSave = !notAutoSave

        $el.on "click", ".task-status", (event) ->
            event.preventDefault()
            event.stopPropagation()

            $el.find(".pop-status").popover().open()

            # pop = $el.find(".pop-status")
            # popoverService.open(pop)

        $el.on "click", ".status", debounce 2000, (event) ->
            event.preventDefault()
            event.stopPropagation()
            target = angular.element(event.currentTarget)
            task.status = target.data("status-id")
            $el.find(".pop-status").popover().close()
            updateTaskStatus($el, task, $scope.taskStatusById)

            if autoSave
                $scope.$apply () ->
                    $repo.save(task).then ->
                        $scope.$eval($attrs.onUpdate)
                        $scope.$emit("related-tasks:status-changed")

        taiga.bindOnce $scope, "project", (project) ->
            $el.append(selectionTemplate({ 'statuses':  project.task_statuses }))
            updateTaskStatus($el, task, $scope.taskStatusById)

            # If the user has not enough permissions the click events are unbinded
            if project.my_permissions.indexOf("modify_task") == -1
                $el.unbind("click")
                $el.find("a").addClass("not-clickable")

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgRelatedTaskStatus", ["$tgRepo", RelatedTaskStatusDirective])

#############################################################################
## jQuery plugin for Popover
#############################################################################

$.fn.popover = () ->
    $el = @

    isVisible = () =>
        $el.css({
            "display": "block",
            "visibility": "hidden"
        })

        docViewTop = $(window).scrollTop()
        docViewBottom = docViewTop + $(window).height()

        elemTop = $el.offset().top
        elemBottom = elemTop + $el.height()

        $el.css({
            "display": "none",
            "visibility": "visible"
        })

        return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop))

    closePopover = (onClose) =>
        if onClose then onClose.call($el)

        $el.fadeOut () =>
            $el
                .removeClass("active")
                .removeClass("fix")

        $el.off("popup:close")


    closeAll = () =>
        $(".popover.active").each () ->
            $(this).trigger("popup:close")

    open = (onClose) =>
        if $el.hasClass("active")
            close()
        else
            closeAll()

            if !isVisible()
                $el.addClass("fix")

            $el
            .fadeIn () =>
                $el.addClass("active")
                $(document.body).off("popover")

                $(document.body).one "click.popover", () =>
                    closeAll()

            $el.on "popup:close", (e) => closePopover(onClose)

    close = () =>
        $el.trigger("popup:close")

    return {open: open, close: close, closeAll: closeAll}
