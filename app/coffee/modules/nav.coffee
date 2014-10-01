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
## Projects Navigation
#############################################################################

class ProjectsNavigationController extends taiga.Controller
    @.$inject = ["$scope", "$rootScope", "$tgResources", "$tgNavUrls", "$projectUrl"]

    constructor: (@scope, @rootscope, @rs, @navurls, @projectUrl) ->
        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL"
            # TODO

        # Listen when someone wants to reload all the projects
        @scope.$on "projects:reload", =>
            @.loadInitialData()

        # Listen when someone has reloaded a project
        @scope.$on "project:loaded", (ctx, project) =>
            @.loadInitialData()

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            for project in projects
                project.url = @projectUrl.get(project)

            @scope.projects = projects
            @scope.filteredProjects = projects
            @scope.filterText = ""
            return projects

    newProject: ->
        @rootscope.$broadcast("projects:create")

    filterProjects: (text) ->
        @scope.filteredProjects = _.filter @scope.projects, (project) ->
            project.name.toLowerCase().indexOf(text) > -1

        @scope.filterText = text
        @rootscope.$broadcast("projects:filtered")

module.controller("ProjectsNavigationController", ProjectsNavigationController)


ProjectsNavigationDirective = ($rootscope, animationFrame, $timeout, tgLoader, $location) ->
    baseTemplate = _.template("""
    <h1>Your projects</h1>
    <form>
        <fieldset>
            <input type="text" placeholder="Search in..." class="search-project"/>
            <a class="icon icon-search"></a>
        </fieldset>
    </form>

    <div class="create-project-button">
        <a class="button button-green" href="">
            Create project
        </a>
    </div>

    <div class="projects-pagination">
        <a class="v-pagination-previous icon icon-arrow-up " href=""></a>
        <div class="v-pagination-list">
            <ul class="projects-list">
            </ul>
        </div>
        <a class="v-pagination-next icon icon-arrow-bottom" href=""></a>
    </div>
    """) # TODO: i18n

    projectsTemplate = _.template("""
    <% _.each(projects, function(project) { %>
    <li>
        <a href="<%- project.url %>">
            <span class="project-name"><%- project.name %></span>
            <span class="icon icon-arrow-right"/>
        </a>
    </li>
    <% }) %>
    """) # TODO: i18n

    overlay = $(".projects-nav-overlay")
    loadingStart = 0

    hideMenu = () ->
        if overlay.is(':visible')
            difftime = new Date().getTime() - loadingStart
            timeoutValue = 0

            if (difftime < 1000)
                timeoutValue = 1000 - timeoutValue

            timeout timeoutValue, ->
                overlay.one 'transitionend', () ->
                    $(document.body).removeClass("loading-project open-projects-nav closed-projects-nav")
                    overlay.hide()

                $(document.body).addClass("closed-projects-nav")

                tgLoader.disablePreventLoading()

    renderProjects  = ($el, projects) ->
        html = projectsTemplate({projects: projects})
        $el.find(".projects-list").html(html)

    render = ($el, projects) ->
        html = baseTemplate()
        $el.html(html)
        renderProjects($el, projects)

    link = ($scope, $el, $attrs, $ctrl) ->
        $ctrl = $el.controller()

        $rootscope.$on("project:loaded", hideMenu)

        overlay.on 'click', () ->
            hideMenu()

        $(document).on 'keydown', (e) =>
            code = if e.keyCode then e.keyCode else e.which
            if code == 27
                hideMenu()

        $scope.$on "nav:projects-list:open", ->
            if !$(document.body).hasClass("open-projects-nav")
                animationFrame.add () ->
                    overlay.show()

            animationFrame.add () ->
                $(document.body).toggleClass("open-projects-nav")

        $el.on "click", ".projects-list > li > a", (event) ->
            # HACK: to solve a problem with the loader when the next url
            #       is equal to the current one
            target = angular.element(event.currentTarget)
            nextUrl = target.prop("href")
            currentUrl = $location.absUrl()
            if nextUrl == currentUrl
                hideMenu()
                return
            # END HACK

            $(document.body).addClass('loading-project')

            tgLoader.preventLoading()

            loadingStart = new Date().getTime()

        $el.on "click", ".create-project-button .button", (event) ->
            event.preventDefault()
            $ctrl.newProject()

        $el.on "keyup", ".search-project", (event) ->
            target = angular.element(event.currentTarget)
            $ctrl.filterProjects(target.val())

        $scope.$on "projects:filtered", ->
            renderProjects($el, $scope.filteredProjects)
            $el.trigger("regenerate:pagination")

        $scope.$watch "projects", (projects) ->
            render($el, $scope.projects) if projects?

    return {link: link}

module.directive("tgProjectsNav", ["$rootScope", "animationFrame", "$timeout", "tgLoader", "$tgLocation",
                                   ProjectsNavigationDirective])


#############################################################################
## Project
#############################################################################

ProjectMenuDirective = ($log, $compile, $auth, $rootscope, $tgAuth, $location, $navUrls) ->
    menuEntriesTemplate = _.template("""
    <div class="menu-container">
        <ul class="main-nav">
        <li id="nav-search">
            <a href="" title="Search">
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
            <a href="<%- project.videoconferenceUrl %>" target="_blank" title="Meet Up">
                <span class="icon icon-video"></span>
                <span class="item">Meet Up</span>
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
                    <li><a href="" class="feedback" title="Feedback"">Feedback</a></li>
                    <li><a href="" title="Logout" class="logout">Logout</a></li>
                </ul>
                <a href="" title="User preferences" class="avatar" id="nav-user-settings">
                    <img src="<%= user.photo %>" alt="<%= user.full_name_display %>" />
                </a>
            </div>
        </div>
    </div>
    """)

    mainTemplate = _.template("""
    <div class="logo-container logo">
        <svg xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg"
             viewBox="0 0 134.2 134.3" version="1.1" preserveAspectRatio="xMidYMid meet" shape-rendering="geometricPrecision">
            <style>
                svg {
                    transform: scale(.99);
                }
                path {
                    fill:#f5f5f5;
                    opacity:0.7;
                }
            </style>
            <g transform="translate(-307.87667,-465.22863)">
                <g class="bottom">
                    <path transform="matrix(-0.14066483,0.99005727,-0.99005727,0.14066483,0,0)"
                          d="m561.8-506.6 42 0 0 42-42 0z" />
                    <path transform="matrix(0.14066483,-0.99005727,0.99005727,-0.14066483,0,0)"
                          d="m-645.7 422.6 42 0 0 42-42 0z" />
                    <path transform="matrix(0.99005727,0.14066483,0.14066483,0.99005727,0,0)"
                          d="m266.6 451.9 42 0 0 42-42 0z" />
                    <path transform="matrix(-0.99005727,-0.14066483,-0.14066483,-0.99005727,0,0)"
                          d="m-350.6-535.9 42 0 0 42-42 0z" />
                </g>
                <g class="top">
                    <path transform="matrix(-0.60061118,-0.79954125,0.60061118,-0.79954125,0,0)"
                          d="m-687.1-62.7 42 0 0 42-42 0z" />
                    <path transform="matrix(-0.79954125,0.60061118,-0.79954125,-0.60061118,0,0)"
                          d="m166.6-719.6 42 0 0 42-42 0z" />
                    <path transform="matrix(0.60061118,0.79954125,-0.60061118,0.79954125,0,0)"
                          d="m603.1-21.3 42 0 0 42-42 0z" />
                    <path transform="matrix(0.79954125,-0.60061118,0.79954125,0.60061118,0,0)"
                          d="m-250.7 635.8 42 0 0 42-42 0z" />
                    <path transform="matrix(0.70710678,0.70710678,-0.70710678,0.70710678,0,0)"
                          d="m630.3 100 22.6 0 0 22.6-22.6 0z" />
                </g>
            </g>
        </svg>
        <span class="item">taiga</span>
    </div>
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
        project = null

        $el.on "click", ".logo", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            console.log target
            $rootscope.$broadcast("nav:projects-list:open")

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
            $rootscope.$broadcast("feedback:show", project)

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
                                   "$tgNavUrls", ProjectMenuDirective])
