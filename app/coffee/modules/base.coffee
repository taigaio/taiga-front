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
# File: modules/base.coffee
###

taiga = @.taiga
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaBase", ["taigaLocales"])


#############################################################################
## Global Page Controller
#############################################################################

class MainTaigaController extends taiga.Controller
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

#############################################################################
## Global Page Directive
#############################################################################

MainTaigaDirective = ($log, $compile, $rootscope) ->
    template = _.template("""
    <h1 class="logo">
        <a href="" title="Home">
            <img src="/images/logo.png" alt="Taiga"/>
        </a>
    </h1>
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
                <span class="icon icon-kanban"></span><span class="item">Kanban</span></a></li>
        <li id="nav-issues">
            <a href="" title="Issues" tg-nav="project-issues:project=project.slug">
                <span class="icon icon-issues"></span><span class="item">Issues</span></a></li>
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

    # WARNING: this code has traces of slighty hacky parts
    # This rerenders and compiles the navigation when ng-view
    # content loaded signal is raised using inner scope.
    renderMainMenu = ($el, targetScope) ->
        container = $el.find(".master > .wrapper")
        menuDom = $el.find("nav.menu")

        dom = $compile(template({}))(targetScope)
        menuDom.empty()
        menuDom.append(dom)

        sectionName = targetScope.section
        menuDom.find("a.active").removeClass("active")
        menuDom.find("#nav-#{sectionName} > a").addClass("active")

    # Link function related to projects navigation
    # part of main menu.
    linkProjecsNav = ($scope, $el, $attrs, $ctrl) ->
        $el.on "click", ".menu .logo > a", (event) ->
            event.preventDefault()
            $el.toggleClass("open-project-nav")

        $el.on "click", ".projects-list > li > a", (event) ->
            $el.toggleClass("open-project-nav")

    linkMenuNav = ($scope, $el, $attrs, $ctrl) ->
        $scope.$on "$viewContentLoaded", (ctx) ->
            if ctx.targetScope.$$childHead is null
                $log.error "No scope found for render menu."
            else
                renderMainMenu($el, ctx.targetScope.$$childHead)

    link = ($scope, $el, $attrs, $ctrl) ->
        linkProjecsNav($scope, $el, $attrs, $ctrl)
        linkMenuNav($scope, $el, $attrs, $ctrl)

    window.onresize = () ->
        $rootscope.$broadcast("resize")

    return {
        controller: MainTaigaController
        link: link
    }


module.directive("tgMain", ["$log", "$compile", "$rootScope", MainTaigaDirective])


#############################################################################
## Navigation
#############################################################################

urls = {
    "home": "/",
    "profile": "/:user",
    "project": "/project/:project",
    "project-backlog": "/project/:project/backlog",
    "project-taskboard": "/project/:project/taskboard/:sprint",
    "project-issues": "/project/:project/issues",
    "project-search": "/project/:project/search",
    "project-issues-detail": "/project/:project/issues/:ref",
    "project-issues-detail-edit": "/project/:project/issues/:ref/edit",

    # Admin
    "project-admin-home": "/project/:project/admin/project-profile/details",
    "project-admin-project-profile-details": "/project/:project/admin/project-profile/details"
}

init = ($log, $navurls) ->
    $log.debug "Initialize navigation urls"
    $navurls.update(urls)

module.run(["$log", "$tgNavUrls", init])
