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
# File: modules/nav.coffee
###

taiga = @.taiga
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
timeout = @.taiga.timeout

module = angular.module("taigaNavMenu", [])


#############################################################################
## Project
#############################################################################

ProjectMenuDirective = ($log, $compile, $auth, $rootscope, $tgAuth, $location, $navUrls, $config, $template) ->
    menuEntriesTemplate = $template.get("project/project-menu.html", true)

    mainTemplate = _.template("""
    <div class="menu-container"></div>
    """)

    # If the last page was kanban or backlog and
    # the new one is the task detail or the us details
    # this method preserve the last section name.
    getSectionName = ($el, sectionName, project) ->
        oldSectionName = $el.find("a.active").parent().attr("id")?.replace("nav-", "")

        if  sectionName  == "backlog-kanban"
            if oldSectionName in ["backlog", "kanban"]
                sectionName = oldSectionName
            else if project.is_backlog_activated && !project.is_kanban_activated
                sectionName = "backlog"
            else if !project.is_backlog_activated && project.is_kanban_activated
                sectionName = "kanban"

        return sectionName

    renderMainMenu = ($el) ->
        html = mainTemplate({})
        $el.html(html)

    # WARNING: this code has traces of slighty hacky parts
    # This rerenders and compiles the navigation when ng-view
    # content loaded signal is raised using inner scope.
    renderMenuEntries = ($el, targetScope, project={}) ->
        container = $el.find(".menu-container")
        sectionName = getSectionName($el, targetScope.section, project)

        ctx = {
            user: $auth.getUser(),
            project: project,
            feedbackEnabled: $config.get("feedbackEnabled")
        }
        dom = $compile(menuEntriesTemplate(ctx))(targetScope)

        dom.find("a.active").removeClass("active")
        dom.find("#nav-#{sectionName} > a").addClass("active")

        container.replaceWith(dom)

    videoConferenceUrl = (project) ->
        urlFixer = (url) -> return url

        if project.videoconferences == "appear-in"
            baseUrl = "https://appear.in/"
        else if project.videoconferences == "talky"
            baseUrl = "https://talky.io/"
        else if project.videoconferences == "jitsi"
            baseUrl = "https://meet.jit.si/"
            urlFixer = (url) -> return url.replace(/ /g, "").replace(/-/g, "")
        else
            return ""

        if project.videoconferences_salt
            url = "#{project.slug}-#{project.videoconferences_salt}"
        else
            url = "#{project.slug}"

        url = urlFixer(url)

        return baseUrl + url


    link = ($scope, $el, $attrs, $ctrl) ->
        renderMainMenu($el)
        project = null

        # $el.on "click", ".logo", (event) ->
        #     event.preventDefault()
        #     target = angular.element(event.currentTarget)
        #     $rootscope.$broadcast("nav:projects-list:open")

        $el.on "click", ".user-settings .avatar", (event) ->
            event.preventDefault()
            $el.find(".user-settings .popover").popover().open()

        $el.on "click", ".logout", (event) ->
            event.preventDefault()
            $auth.logout()
            $scope.$apply ->
                $location.path($navUrls.resolve("login"))

        $el.on "click", "#nav-search > a", (event) ->
            event.preventDefault()
            $rootscope.$broadcast("search-box:show", project)

        $el.on "click", ".feedback", (event) ->
            event.preventDefault()
            $rootscope.$broadcast("feedback:show")

        $scope.$on "projects:loaded", (listener) ->
            $el.addClass("hidden")
            listener.stopPropagation()

        $scope.$on "project:loaded", (ctx, newProject) ->
            project = newProject
            if $el.hasClass("hidden")
                $el.removeClass("hidden")

            project.videoconferenceUrl = videoConferenceUrl(project)
            renderMenuEntries($el, ctx.targetScope, project)

    return {link: link}

module.directive("tgProjectMenu", ["$log", "$compile", "$tgAuth", "$rootScope", "$tgAuth", "$tgLocation",
                                   "$tgNavUrls", "$tgConfig", "$tgTemplate", ProjectMenuDirective])
