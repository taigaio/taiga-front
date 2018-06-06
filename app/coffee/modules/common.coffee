###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
DataPickerConfig = ($translate, $config, $auth) ->
    return {
        get: () ->
            user = $auth.getUser()
            lang = user.lang || $translate.preferredLanguage()
            rtlLanguages = $config.get("rtlLanguages", [])
            isRTL = rtlLanguages.indexOf(lang) > -1
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
                isRTL: isRTL,
                firstDay: parseInt($translate.instant("COMMON.PICKERDATE.FIRST_DAY_OF_WEEK"), 10),
                format: $translate.instant("COMMON.PICKERDATE.FORMAT")
            }
    }

module.factory("tgDatePickerConfigService", ["$translate", "$tgConfig", "$tgAuth", DataPickerConfig])

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

CheckPermissionDirective = (projectService) ->
    render = ($el, project, permission) ->
        if project && permission
            $el.removeClass('hidden') if project.get('my_permissions').indexOf(permission) > -1

    link = ($scope, $el, $attrs) ->
        $el.addClass('hidden')
        permission = $attrs.tgCheckPermission

        unwatch = $scope.$watch () ->
            return projectService.project
        , () ->
            return if !projectService.project

            render($el, projectService.project, permission)
            unwatch()

        unObserve = $attrs.$observe "tgCheckPermission", (permission) ->
            return if !permission

            render($el, projectService.project, permission)
            unObserve()

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

CheckPermissionDirective.$inject = [
    "tgProjectService"
]

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
        if project.toJS
            project = project.toJS()

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
## Queue model transformation
#############################################################################

class QueueModelTransformation extends taiga.Service
    @.$inject = [
        "$tgQqueue",
        "$tgRepo",
        "$q",
        "$tgModel"
    ]

    constructor: (@qqueue, @repo, @q, @model) ->

    setObject: (@scope, @prop) ->

    clone: () ->
        attrs = _.cloneDeep(@.scope[@.prop]._attrs)
        model = @model.make_model(@.scope[@.prop]._name, attrs)

        return model

    getObj: () ->
        return @.scope[@.prop]

    save: (transformation) ->
        defered = @q.defer()
        @qqueue.add () =>
            obj = @.getObj()
            comment = obj.comment

            obj.comment = ''

            clone = @.clone()

            modified = _.omit(obj._modifiedAttrs, ['version'])
            clone = _.assign(clone, modified)

            transformation(clone)

            if comment.length
                clone.comment = comment

            success = () =>
                @.scope[@.prop] = clone

                defered.resolve.apply(null, arguments)

            @repo.save(clone).then(success, defered.reject)

        return defered.promise

module.service("$tgQueueModelTransformation", QueueModelTransformation)

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

Capslock = () ->
    template = """
        <tg-svg class="capslock" ng-if="capslockIcon && iscapsLockActivated" svg-icon='icon-capslock' svg-title='COMMON.CAPSLOCK_WARNING'></tg-svg>
    """

    return {
        template: template
    }

module.directive("tgCapslock", [Capslock])

LightboxClose = () ->
    template = """
        <a class="close" ng-click="onClose()" href="" title="{{'COMMON.CLOSE' | translate}}">
            <tg-svg svg-icon="icon-close"></tg-svg>
        </a>
    """

    link = (scope, elm, attrs) ->

    return {
        scope: {
            onClose: '&'
        },
        link: link,
        template: template
    }

module.directive("tgLightboxClose", [LightboxClose])

Svg = () ->
    template = """
    <svg class="{{ 'icon ' + svgIcon }}" style="fill: {{ svgFill }}">
        <use xlink:href="" ng-attr-xlink:href="{{ '#' + svgIcon }}">
            <title ng-if="svgTitle">{{svgTitle}}</title>
            <title ng-if="svgTitleTranslate">{{svgTitleTranslate | translate: svgTitleTranslateValues}}</title>
        </use>
    </svg>
    """

    return {
        scope: {
            svgIcon: "@",
            svgTitle: "@",
            svgTitleTranslate: "@",
            svgTitleTranslateValues: "=",
            svgFill: "="
        },
        template: template
    }

module.directive("tgSvg", [Svg])

Autofocus = ($timeout, $parse, animationFrame) ->
  return {
    restrict: 'A',
    link : ($scope, $element, attrs) ->
        if attrs.ngShow
            model = $parse(attrs.ngShow)

            $scope.$watch model, (value) ->
                if value == true
                    $timeout () -> $element[0].focus()

        else
            $timeout () -> $element[0].focus()
  }

module.directive('tgAutofocus', ['$timeout', '$parse', "animationFrame", Autofocus])

module.directive 'tgPreloadImage', () ->
    spinner = "<img class='loading-spinner' src='/" + window._version + "/svg/spinner-circle.svg' alt='loading...' />"

    template = """
        <div>
            <ng-transclude></ng-transclude>
        </div>
    """

    preload = (src, onLoad) ->
        image = new Image()
        image.onload = onLoad
        image.src = src

        return image

    return {
        template: template,
        transclude: true,
        replace: true,
        link: (scope, el, attrs) ->
            image = el.find('img:last')
            timeout = null

            onLoad = () ->
                el.find('.loading-spinner').remove()
                image.show()

                if timeout
                    clearTimeout(timeout)
                    timeout = null

            attrs.$observe 'preloadSrc', (src) ->
                if timeout
                    clearTimeout(timeout)

                el.find('.loading-spinner').remove()

                timeout = setTimeout () ->
                    el.prepend(spinner)
                , 200

                image.hide()

                preload(src, onLoad)
    }


#############################################################################
## Disable link href when Ctrl Key is pressed
#############################################################################

CtrlClickDisable = () ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", ($event) ->
            if ($event.ctrlKey || $event.metaKey)
                $event.preventDefault()
    return {link: link}

module.directive("tgCtrlClickDisable", CtrlClickDisable)
