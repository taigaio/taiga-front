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
        @scope.$apply () =>
            @rootscope.$broadcast("projects:create")

    filterProjects: (text) ->
        @scope.filteredProjects = _.filter @scope.projects, (project) ->
            project.name.toLowerCase().indexOf(text) > -1

        @scope.filterText = text
        @rootscope.$broadcast("projects:filtered")

module.controller("ProjectsNavigationController", ProjectsNavigationController)


ProjectsNavigationDirective = ($rootscope, animationFrame, $timeout, tgLoader, $location, $compile) ->
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

    <div class="projects-pagination" tg-projects-pagination>
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


    link = ($scope, $el, $attrs, $ctrls) ->
        $ctrl = $ctrls[0]
        $rootscope.$on("project:loaded", hideMenu)

        renderProjects  = (projects) ->
            html = projectsTemplate({projects: projects})
            $el.find(".projects-list").html(html)

            $scope.$emit("regenerate:project-pagination")

        render = (projects) ->
            $el.html($compile(baseTemplate())($scope))
            renderProjects(projects)

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

        $scope.$watch "projects", (projects) ->
            render(projects) if projects?

    return {
        require: ["tgProjectsNav"]
        controller: ProjectsNavigationController
        link: link
    }


module.directive("tgProjectsNav", ["$rootScope", "animationFrame", "$timeout", "tgLoader", "$tgLocation", "$compile", ProjectsNavigationDirective])


#############################################################################
## Project
#############################################################################

ProjectMenuDirective = ($log, $compile, $auth, $rootscope, $tgAuth, $location, $navUrls, $config) ->
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
        <li id="nav-team">
            <a href="" title="Team" tg-nav="project-team:project=project.slug">
                <span class="icon icon-team"></span>
                <span class="item">Team</span>
            </a>
        </li>
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
                    <% if (feedbackEnabled) { %>
                    <li><a href="" class="feedback" title="Feedback"">Feedback</a></li>
                    <% } %>
                    <li><a href="" title="Logout" class="logout">Logout</a></li>
                </ul>
                <a href="" title="User preferences" class="avatar" id="nav-user-settings">
                    <img src="<%- user.photo %>" alt="<%- user.full_name_display %>" />
                </a>
            </div>
        </div>
    </div>
    """)

    mainTemplate = _.template("""
    <div class="logo-container logo">
        <svg xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" version="1.1" preserveAspectRatio="xMidYMid meet">
            <style>
                path {
                    fill:#f5f5f5;
                    opacity:0.7;
                }
                .moustache {
                    fill:#000;
                }
            </style>
            <g transform="translate(0,-52.362183)">
                <g transform="matrix(1.1783562,0,0,1.1783562,2450.4425,-1298.9778)">
                    <path transform="matrix(-0.1406648,0.99005728,-0.99005728,0.14066481,0,0)" d="m1114.3 1212.6 263 0 0 263-263 0z" />
                    <path transform="matrix(0.1406648,-0.99005728,0.99005728,-0.14066481,0,0)" d="m-1640.3-1738.9 263 0 0 263-263 0z" />
                    <path transform="matrix(0.99005728,0.1406648,0.14066481,0.99005728,0,0)" d="m-2199.2 1599.4 263 0 0 263-263 0z" />
                    <path transform="matrix(-0.99005728,-0.1406648,-0.14066481,-0.99005728,0,0)" d="m1673.2-2125.1 263 0 0 263-263 0z" />
                    <path transform="matrix(-0.60061118,-0.79954125,0.60061117,-0.79954125,0,0)" d="m132.1-2623.1 263 0 0 263-263 0z" />
                    <path transform="matrix(-0.79954125,0.60061118,-0.79954125,-0.60061117,0,0)" d="m2079.7-535.4 263 0 0 263-263 0z" />
                    <path transform="matrix(0.60061118,0.79954125,-0.60061118,0.79954125,0,0)" d="m-658.4 2097.4 263 0 0 263-263 0z" />
                    <path transform="matrix(0.79954125,-0.60061118,0.79954125,0.60061117,0,0)" d="m-2606.2 10.1 263 0 0 263-263 0z" />
                    <path transform="matrix(0.70710678,0.70710678,-0.70710678,0.70710678,0,0)" d="m-130.2 2210.7 141.4 0 0 141.4-141.4 0z" />
                </g>
            </g>
            <path class="moustache" d="m197.1 669.9c0 0-11.5 83.8 58.5 113.8 60.9 26.1 109.3 13 144.4 0.7 35.1-12.4 98.9-66.3 98.9-66.3 0 0 92.3 74.1 154.1 80.6 61.8 6.5 100.4-9.5 119-28 45.1-44.9 34.5-102.8 34.5-102.8 0 0-43.6 31.9-88.4 11.7-44.9-20.2-63.7-73.6-109.8-90.5-46.2-16.9-78.1 0.8-91.8 13.1-13.7 12.4-15.6 16.9-15.6 16.9 0 0-28-31.2-63.1-33.8-35.1-2.6-59.8 15.6-91 46.2-31.2 30.6-48.1 54-83.9 55.3-35.8 1.3-65.7-16.9-65.7-16.9z" />
        </svg>
        <span class="item">taiga<sup>[beta]</sup></span>
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
                                   "$tgNavUrls", "$tgConfig", ProjectMenuDirective])
