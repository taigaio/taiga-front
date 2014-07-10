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
    @.$inject = ["$scope", "$tgResources"]

    constructor: (@scope, @rs) ->
        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL"
            # TODO

    loadInitialData: ->
        return @rs.projects.list().then (projects) =>
            @scope.projects = projects
            return projects


ProjectsNavigationDirective = ->
    link = ($scope, $el, $attrs, $ctrl) ->

    return {
        link: link
        controller: ProjectsNavigationController
    }


module.directive("tgProjectsNav", ProjectsNavigationDirective)


#############################################################################
## Project
#############################################################################

ProjectMenuDirective = ($log, $compile, $rootscope) ->
    menuEntriesTemplate = _.template("""
    <ul class="main-nav">
    <li id="nav-search">
        <a href="" title="Search" tg-nav="project-search:project=project.slug">
            <span class="icon icon-search"></span><span class="item">Search</span>
        </a>
    </li>
    <li id="nav-backlog" tg-nav="project-backlog:project=project.slug">
        <a href="" title="Backlog" tg-nav="project-backlog:project=project.slug">
            <span class="icon icon-backlog"></span>
            <span class="item">Backlog</span>
        </a>
    </li>
    <li id="nav-kanban">
        <a href="" title="Kanban">
            <span class="icon icon-kanban"></span><span class="item">Kanban</span>
        </a>
    </li>
    <li id="nav-issues">
        <a href="" title="Issues" tg-nav="project-issues:project=project.slug">
            <span class="icon icon-issues"></span><span class="item">Issues</span>
        </a>
    </li>
    <li id="nav-wiki">
        <a href="" title="Wiki">
            <span class="icon icon-wiki"></span>
            <span class="item">Wiki</span>
        </a>
    </li>
    <li id="nav-video">
        <a href="" title="Video">
            <span class="icon icon-video"></span>
            <span class="item">Video</span>
        </a>
    </li>
    <li id="nav-admin">
        <a href="" tg-nav="project-admin-home:project=project.slug" title="Admin">
            <span class="icon icon-settings"></span>
            <span class="item">Admin</span>
        </a>
    </li>
    </ul>
    """)

    mainTemplate = _.template("""
    <h1 class="logo">
        <a href="" title="Home">
            <img src="/images/logo.png" alt="Taiga"/>
        </a>
    </h1>
    <ul class="main-nav"></ul>
    <div class="user">
        <div class="user-settings">
            <ul class="popover">
                <li><a href="" title="Change profile photo">Change profile photo</a></li>
                <li><a href="" title="Account settings">Account settings</a></li>
                <li><a href="" title="Logout">Logout</a></li>
            </ul>
            <a href="" title="User preferences" class="avatar">
                <img src="http://thecodeplayer.com/u/uifaces/12.jpg" alt="username"/>
            </a>
        </div>
    </div>
    """)

    renderMainMenu = ($el) ->
        html = mainTemplate({})
        $el.html(html)

    # WARNING: this code has traces of slighty hacky parts
    # This rerenders and compiles the navigation when ng-view
    # content loaded signal is raised using inner scope.
    renderMenuEntries = ($el, targetScope) ->
        container = $el.find("ul.main-nav")
        sectionName = targetScope.section

        dom = $compile(menuEntriesTemplate({}))(targetScope)
        dom.find("a.active").removeClass("active")
        dom.find("#nav-#{sectionName} > a").addClass("active")

        container.replaceWith(dom)


    link = ($scope, $el, $attrs, $ctrl) ->
        renderMainMenu($el)

        $scope.$on "$viewContentLoaded", (ctx) ->
            if ctx.targetScope.$$childHead is null
                $log.error "No scope found for render menu."
                return

            if $el.hasClass("hidden")
                $el.removeClass("hidden")

            renderMenuEntries($el, ctx.targetScope.$$childHead)

    return {link: link}


module.directive("tgProjectMenu", ["$log", "$compile", "$rootScope", ProjectMenuDirective])


