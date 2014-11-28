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
# File: modules/common.coffee
###

taiga = @.taiga

module = angular.module("taigaCommon", [])

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
## Set the page title
#############################################################################

AppTitle = () ->
    set = (text) ->
        $("title").text(text)

    return {set: set}

module.factory("$appTitle", AppTitle)

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
