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

module = angular.module("taigaNavMenu", [])

#############################################################################
## Projects Navigation
#############################################################################
class ProjectsNavigationController extends taiga.Controller
    @.$inject = ["$scope", "$tgResources", "$tgNavUrls"]

    constructor: (@scope, @rs, @navurls) ->
        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL"
            # TODO

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            @scope.projects = projects
            for project in projects
                if project.is_backlog_activated and project.my_permissions.indexOf("view_us")>-1
                    url = @navurls.resolve("project-backlog")
                else if project.is_kanban_activated and project.my_permissions.indexOf("view_us")>-1
                    url = @navurls.resolve("project-kanban")
                else if project.is_wiki_activated and project.my_permissions.indexOf("view_wiki_pages")>-1
                    url = @navurls.resolve("project-wiki")
                else if project.is_issues_activated and project.my_permissions.indexOf("view_issues")>-1
                    url = @navurls.resolve("project-issues")
                else
                    url = @navurls.resolve("project")

                project.url = @navurls.formatUrl(url, {'project': project.slug})
            return projects


ProjectsNavigationDirective = ($rootscope, animationFrame) ->
    overlay = $(".projects-nav-overlay")
    loadingStart = 0
    hideMenu = () ->
        if overlay.is(':visible')
            difftime = new Date().getTime() - loadingStart
            timeout = 0

            if (difftime < 3500)
                timeout = 3500 - timeout

            setTimeout ( ->
                overlay.one 'transitionend', () ->
                    overlay.hide()

                $(document.body)
                    .removeClass("loading-project open-projects-nav")
            ), timeout

    link = ($scope, $el, $attrs, $ctrl) ->
        $rootscope.$on("project:loaded", hideMenu)

        overlay.on 'click', () ->
            hideMenu()

        $scope.$on "nav:projects-list:open", ->
            if !$(document.body).hasClass("open-projects-nav")
                animationFrame.add () ->
                    overlay.show()

            animationFrame.add () ->
                $(document.body).toggleClass("open-projects-nav")

        $el.on "click", ".projects-list > li > a", (event) ->
            $(document.body)
                .addClass('loading-project')

            loadingStart = new Date().getTime()

    return {
        link: link
        controller: ProjectsNavigationController
    }


module.directive("tgProjectsNav", ["$rootScope", "animationFrame", ProjectsNavigationDirective])


#############################################################################
## Project
#############################################################################

ProjectMenuDirective = ($log, $compile, $auth, $rootscope, $tgAuth, $location) ->
    menuEntriesTemplate = _.template("""
    <div class="menu-container">
        <ul class="main-nav">
        <li id="nav-search">
            <a href="" title="Search" tg-nav="project-search:project=project.slug">
                <span class="icon icon-search"></span><span class="item">Search</span>
            </a>
        </li>
        <% if (project.is_backlog_activated && project.my_permissions.indexOf("view_us") != -1) { %>
        <li id="nav-backlog">
            <a href="" title="Backlog" tg-nav="project-backlog:project=project.slug">
                <span class="icon icon-backlog"></span>
                <span class="item">Backlog</span>
            </a>
        </li>
        <% } %>
        <% if (project.is_kanban_activated && project.my_permissions.indexOf("view_us") != -1) { %>
        <li id="nav-kanban">
            <a href="" title="Kanban" tg-nav="project-kanban:project=project.slug">
                <span class="icon icon-kanban"></span><span class="item">Kanban</span>
            </a>
        </li>
        <% } %>
        <% if (project.is_issues_activated && project.my_permissions.indexOf("view_issues") != -1) { %>
        <li id="nav-issues">
            <a href="" title="Issues" tg-nav="project-issues:project=project.slug">
                <span class="icon icon-issues"></span><span class="item">Issues</span>
            </a>
        </li>
        <% } %>
        <% if (project.is_wiki_activated && project.my_permissions.indexOf("view_wiki_pages") != -1) { %>
        <li id="nav-wiki">
            <a href="" title="Wiki" tg-nav="project-wiki:project=project.slug">
                <span class="icon icon-wiki"></span>
                <span class="item">Wiki</span>
            </a>
        </li>
        <% } %>
        <% if (project.videoconferences) { %>
        <li id="nav-video">
            <a href="<%- project.videoconferenceUrl %>" target="_blank" title="Video">
                <span class="icon icon-video"></span>
                <span class="item">Video</span>
            </a>
        </li>
        <% } %>
        <% if (project.i_am_owner) { %>
        <li id="nav-admin">
            <a href="" tg-nav="project-admin-home:project=project.slug" title="Admin">
                <span class="icon icon-settings"></span>
                <span class="item">Admin</span>
            </a>
        </li>
        <% } %>
        </ul>
        <div class="user">
            <div class="user-settings">
                <ul class="popover">
                    <li><a href="" title="User Profile", tg-nav="user-settings-user-profile:project=project.slug">User Profile</a></li>
                    <li><a href="" title="Change Password", tg-nav="user-settings-user-change-password:project=project.slug">Change Password</a></li>
                    <li><a href="" title="Notifications", tg-nav="user-settings-mail-notifications:project=project.slug">Notifications</a></li>
                    <li><a href="" title="Logout" class="logout">Logout</a></li>
                </ul>
                <a href="" title="User preferences" class="avatar" id="nav-user-settings">
                    <img src="{{ user.photo }}" alt="{{ user.full_name_display }}" />
                </a>
            </div>
        </div>
    </div>
    """)

    mainTemplate = _.template("""
    <h1 class="logo">
        <a href="" title="Home">
            <img src="/images/logo.png" alt="Taiga"/>
        </a>
    </h1>
    <div class="menu-container"></div>
    """)

    renderMainMenu = ($el) ->
        html = mainTemplate({})
        $el.html(html)

    # WARNING: this code has traces of slighty hacky parts
    # This rerenders and compiles the navigation when ng-view
    # content loaded signal is raised using inner scope.
    renderMenuEntries = ($el, targetScope, project={}) ->
        container = $el.find(".menu-container")
        sectionName = targetScope.section
        dom = $compile(menuEntriesTemplate({user: $auth.getUser(), project: project}))(targetScope)
        dom.find("a.active").removeClass("active")
        dom.find("#nav-#{sectionName} > a").addClass("active")

        container.replaceWith(dom)

    videoConferenceUrl = (project) ->
        if project.videoconferences == "appear-in"
            baseUrl = "https://appear.in/"
        else if project.videoconferences == "talky"
            baseUrl = "https://talky.io/"
        else
            return ""

        if project.videoconferences_salt
            url = "#{project.slug}-#{project.videoconferences_salt}"
        else
            url = "#{project.slug}"

        return baseUrl + url


    link = ($scope, $el, $attrs, $ctrl) ->
        renderMainMenu($el)

        $el.on "click", ".logo > a", (event) ->
            event.preventDefault()
            $rootscope.$broadcast("nav:projects-list:open")

        $el.on "click", ".user-settings .avatar", (event) ->
            event.preventDefault()
            $el.find(".user-settings .popover").popover().open()

        $el.on "click", ".logout", (event) ->
            event.preventDefault()
            $auth.logout()
            $scope.$apply ->
                $location.path("/login")

        $scope.$on "project:loaded", (ctx, project) ->
            if $el.hasClass("hidden")
                $el.removeClass("hidden")

            project.videoconferenceUrl = videoConferenceUrl(project)
            renderMenuEntries($el, ctx.targetScope, project)

    return {link: link}


module.directive("tgProjectMenu", ["$log", "$compile", "$tgAuth", "$rootScope", "$tgAuth", "$tgLocation", ProjectMenuDirective])
