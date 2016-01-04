###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/common.coffee
###

taiga = @.taiga

module = angular.module("taigaCommon", [])

#############################################################################
## Default datepicker config
#############################################################################
DataPickerConfig = ($translate) ->
    return {
        get: () ->
            return {
                i18n: {
                    previousMonth: $translate.instant("COMMON.PICKERDATE.PREV_MONTH"),
                    nextMonth:  $translate.instant("COMMON.PICKERDATE.NEXT_MONTH"),
                    months: [
                        $translate.instant("COMMON.PICKERDATE.MONTHS.JAN"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.FEB"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.MAR"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.APR"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.MAY"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.JUN"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.JUL"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.AUG"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.SEP"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.OCT"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.NOV"),
                        $translate.instant("COMMON.PICKERDATE.MONTHS.DEC")
                    ],
                    weekdays: [
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.SUN"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.MON"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.TUE"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.WED"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.THU"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.FRI"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS.SAT")
                    ],
                    weekdaysShort: [
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.SUN"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.MON"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.TUE"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.WED"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.THU"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.FRI"),
                        $translate.instant("COMMON.PICKERDATE.WEEK_DAYS_SHORT.SAT")
                    ]
                },
                isRTL: $translate.instant("COMMON.PICKERDATE.IS_RTL") == "true",
                firstDay: parseInt($translate.instant("COMMON.PICKERDATE.FIRST_DAY_OF_WEEK"), 10),
                format: $translate.instant("COMMON.PICKERDATE.FORMAT")
            }
    }

module.factory("tgDatePickerConfigService", ["$translate", DataPickerConfig])

#############################################################################
## Get the selected text
#############################################################################
SelectedText = ($window, $document) ->
    get = () ->
        if $window.getSelection
            return $window.getSelection().toString()
        else if $document.selection
            return $document.selection.createRange().text
        return ""

    return {get: get}

module.factory("$selectedText", ["$window", "$document", SelectedText])

#############################################################################
## Permission directive, hide elements when necessary
#############################################################################

CheckPermissionDirective = ->
    render = ($el, project, permission) ->
        $el.removeClass('hidden') if project.my_permissions.indexOf(permission) > -1

    link = ($scope, $el, $attrs) ->
        $el.addClass('hidden')
        permission = $attrs.tgCheckPermission

        $scope.$watch "project", (project) ->
            render($el, project, permission) if project?

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgCheckPermission", CheckPermissionDirective)

#############################################################################
## Add class based on permissions
#############################################################################

ClassPermissionDirective = ->
    name = "tgClassPermission"

    link = ($scope, $el, $attrs) ->
        checkPermissions = (project, className, permission) ->
            negation = permission[0] == "!"

            permission = permission.slice(1) if negation

            if negation && project.my_permissions.indexOf(permission) == -1
                $el.addClass(className)
            else if !negation && project.my_permissions.indexOf(permission) != -1
                $el.addClass(className)
            else
                $el.removeClass(className)

        tgClassPermissionWatchAction = (project) ->
            if project
                unbindWatcher()

                classes = $scope.$eval($attrs[name])

                for className, permission of classes
                    checkPermissions(project, className, permission)


        unbindWatcher = $scope.$watch "project", tgClassPermissionWatchAction

    return {link:link}

module.directive("tgClassPermission", ClassPermissionDirective)

#############################################################################
## Animation frame service, apply css changes in the next render frame
#############################################################################
AnimationFrame = () ->
    animationFrame =
        window.requestAnimationFrame       ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame

    performAnimation = (time) =>
        fn = tail.shift()
        fn()

        if (tail.length)
            animationFrame(performAnimation)

    tail = []

    add = () ->
        for fn in arguments
            tail.push(fn)

            if tail.length == 1
                animationFrame(performAnimation)

    return {add: add}

module.factory("animationFrame", AnimationFrame)

#############################################################################
## Open/close comment
#############################################################################

ToggleCommentDirective = () ->
    link = ($scope, $el, $attrs) ->
        $el.find("textarea").on "focus", () ->
            $el.addClass("active")

    return {link:link}

module.directive("tgToggleComment", ToggleCommentDirective)


#############################################################################
## Get the appropiate section url for a project
## according to his enabled modules and user permisions
#############################################################################

ProjectUrl = ($navurls) ->
    get = (project) ->
        ctx = {project: project.slug}

        if project.is_backlog_activated and project.my_permissions.indexOf("view_us") > -1
            return $navurls.resolve("project-backlog", ctx)
        if project.is_kanban_activated and project.my_permissions.indexOf("view_us") > -1
            return $navurls.resolve("project-kanban", ctx)
        if project.is_wiki_activated and project.my_permissions.indexOf("view_wiki_pages") > -1
            return $navurls.resolve("project-wiki", ctx)
        if project.is_issues_activated and project.my_permissions.indexOf("view_issues") > -1
            return $navurls.resolve("project-issues", ctx)

        return $navurls.resolve("project", ctx)

    return {get: get}

module.factory("$projectUrl", ["$tgNavUrls", ProjectUrl])


#############################################################################
## Limite line size in a text area
#############################################################################

LimitLineLengthDirective = () ->
    link = ($scope, $el, $attrs) ->
        maxColsPerLine = parseInt($el.attr("cols"))
        $el.on "keyup", (event) ->
            code = event.keyCode
            lines = $el.val().split("\n")

            _.each lines, (line, index) ->
                lines[index] = line.substring(0, maxColsPerLine - 2)

            $el.val(lines.join("\n"))

    return {link:link}

module.directive("tgLimitLineLength", LimitLineLengthDirective)

#############################################################################
## Queue Q promises
#############################################################################

Qqueue = ($q) ->
    deferred = $q.defer()
    deferred.resolve()

    lastPromise = deferred.promise

    qqueue = {
        bindAdd: (fn) =>
            return (args...) =>
                lastPromise = lastPromise.then () => fn.apply(@, args)

            return qqueue
        add: (fn) =>
            if !lastPromise
                lastPromise = fn()
            else
                lastPromise = lastPromise.then(fn)

            return qqueue
    }

    return qqueue

module.factory("$tgQqueue", ["$q", Qqueue])

#############################################################################
## Templates
#############################################################################

Template = ($templateCache) ->
    return {
        get: (name, lodash = false) =>
            tmp = $templateCache.get(name)

            if lodash
                tmp = _.template(tmp)

            return tmp
    }

module.factory("$tgTemplate", ["$templateCache", Template])

#############################################################################
## Permission directive, hide elements when necessary
#############################################################################

Capslock = ($translate) ->
    link = ($scope, $el, $attrs) ->
        open = false

        warningIcon = $('<div>')
            .addClass('icon')
            .addClass('icon-capslock')
            .attr('title', $translate.instant('COMMON.CAPSLOCK_WARNING'))

        hideIcon = () ->
            warningIcon.fadeOut () ->
                open = false

                $(this).remove()

        showIcon = (e) ->
            return if open
            element = e.currentTarget
            $(element).parent().append(warningIcon)
            $('.icon-capslock').fadeIn()

            open = true

        $el.on 'blur', (e) ->
            hideIcon()

        $el.on 'keyup.capslock, focus', (e) ->
            if $el.val() == $el.val().toLowerCase()
                hideIcon(e)
            else
                showIcon(e)

        $scope.$on "$destroy", ->
            $el.off('.capslock')

    return {link:link}

module.directive("tgCapslock", ["$translate", Capslock])
