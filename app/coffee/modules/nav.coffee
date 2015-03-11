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
        return @rs.projects.listByMember(@rootscope.user.id).then (projects) =>
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


ProjectsNavigationDirective = ($rootscope, animationFrame, $timeout, tgLoader, $location, $compile, $template) ->
    baseTemplate = $template.get("project/project-navigation-base.html", true)
    projectsTemplate = $template.get("project/project-navigation-list.html", true)

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
                    $(document.body)
                        .removeClass("loading-project open-projects-nav closed-projects-nav")
                        .css("overflow-x", "visible")

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
                animationFrame.add () => overlay.show()

            animationFrame.add(
                () => $(document.body).css("overflow-x", "hidden")
                () => $(document.body).toggleClass("open-projects-nav")
            )

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

        $el.on "click", ".create-project-button", (event) ->
            event.preventDefault()
            $ctrl.newProject()

        $el.on "keyup", ".search-project", (event) ->
            target = angular.element(event.currentTarget)
            $ctrl.filterProjects(target.val())

        $scope.$on "projects:filtered", ->
            renderProjects($scope.filteredProjects)

        $scope.$watch "projects", (projects) ->
            render(projects) if projects?

    return {
        require: ["tgProjectsNav"]
        controller: ProjectsNavigationController
        link: link
    }


module.directive("tgProjectsNav", ["$rootScope", "animationFrame", "$timeout", "tgLoader", "$tgLocation", "$compile",
                                   "$tgTemplate", ProjectsNavigationDirective])


#############################################################################
## Project
#############################################################################

ProjectMenuDirective = ($log, $compile, $auth, $rootscope, $tgAuth, $location, $navUrls, $config, $template) ->
    menuEntriesTemplate = $template.get("project/project-menu.html", true)

    mainTemplate = _.template("""
    <div class="logo-container logo">
        <svg xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 134.2 134.3" version="1.1" preserveAspectRatio="xMidYMid meet">
            <style>
                path {
                    fill:#f5f5f5;
                    opacity:0.7;
                }
            </style>
            <g transform="translate(-307.87667,-465.22863)">
                <g class="bottom">
                    <path transform="matrix(-0.14066483,0.99005727,-0.99005727,0.14066483,0,0)" d="m561.8-506.6 42 0 0 42-42 0z" />
                    <path transform="matrix(0.14066483,-0.99005727,0.99005727,-0.14066483,0,0)" d="m-645.7 422.6 42 0 0 42-42 0z" />
                    <path transform="matrix(0.99005727,0.14066483,0.14066483,0.99005727,0,0)" d="m266.6 451.9 42 0 0 42-42 0z" />
                    <path transform="matrix(-0.99005727,-0.14066483,-0.14066483,-0.99005727,0,0)" d="m-350.6-535.9 42 0 0 42-42 0z" />
                </g>
                <g class="top">
                    <path transform="matrix(-0.60061118,-0.79954125,0.60061118,-0.79954125,0,0)" d="m-687.1-62.7 42 0 0 42-42 0z" />
                    <path transform="matrix(-0.79954125,0.60061118,-0.79954125,-0.60061118,0,0)" d="m166.6-719.6 42 0 0 42-42 0z" />
                    <path transform="matrix(0.60061118,0.79954125,-0.60061118,0.79954125,0,0)" d="m603.1-21.3 42 0 0 42-42 0z" />
                    <path transform="matrix(0.79954125,-0.60061118,0.79954125,0.60061118,0,0)" d="m-250.7 635.8 42 0 0 42-42 0z" />
                    <path transform="matrix(0.70710678,0.70710678,-0.70710678,0.70710678,0,0)" d="m630.3 100 22.6 0 0 22.6-22.6 0z" />
                </g>
            </g>
        </svg>
        <span class="item">taiga<sup>[beta]</sup></span>
    </div>
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
                                   "$tgNavUrls", "$tgConfig", "$tgTemplate", ProjectMenuDirective])
