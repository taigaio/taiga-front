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
            console.log projects
            @scope.projects = projects
            return projects

#############################################################################
## Global Page Directive
#############################################################################


MainTaigaDirective = ($log, $compile, $rootscope) ->
    template = _.template("""
    <h1 class="logo"><a href="" title="Home"><img src="/images/logo.png" alt="Taiga"/></a></h1>
    <ul class="main-nav">
        <li data-name="search">
            <a href="" title="Search" tg-nav="project-search:project=project.slug">
                <span class="icon icon-search"></span><span class="item">Search</span>
            </a>
        </li>
        <li data-name="backlog" tg-nav="project-backlog:project=project.slug">
            <a href="" title="Backlog" tg-nav="project-backlog:project=project.slug">
                <span class="icon icon-backlog"></span>
                <span class="item">Backlog</span>
            </a>
        </li>
        <li data-name="kanban">
            <a href="" title="Kanban">
                <span class="icon icon-kanban"></span><span class="item">Kanban</span></a></li>
        <li data-name="issues">
            <a href="" title="Issues" tg-nav="project-issues:project=project.slug">
                <span class="icon icon-issues"></span><span class="item">Issues</span></a></li>
        <li data-name="wiki">
            <a href="" title="Wiki">
                <span class="icon icon-wiki"></span>
                <span class="item">Wiki</span>
            </a>
        </li>
        <li data-name="video">
            <a href="" title="Video">
                <span class="icon icon-video"></span>
                <span class="item">Video</span>
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
    <div class="settings">
        <a href="" title="User preferences">Pilar</a>
        <a href="" title="Site preferences">
            <span class="icon icon-settings"></span>
        </a>
    </div>""")

    # WARNING: this code has traces of slighty hacky parts
    # This rerenders and compiles the navigation when ng-view
    # content loaded signal is raised using inner scope.
    renderMainMenu = ($el, targetScope) ->
        container = $el.find(".master > .wrapper")
        dom = $compile(template({}))(targetScope)

        menuDom = $el.find("nav.menu")
        menuDom.empty()
        menuDom.append(dom)

        sectionName = targetScope.section
        menuDom.find("a.active").removeClass("active")
        menuDom.find("[data-name=#{sectionName}] > a").addClass("active")

    # Link function related to projects navigation
    # part of main menu.
    linkProjecsNav = ($scope, $el, $attrs, $ctrl) ->
        $el.addClass("closed-project-nav")

        $el.on "click", ".menu .logo > a", (event) ->
            event.preventDefault()
            $el.toggleClass("closed-project-nav")
            $el.toggleClass("open-project-nav")

        $el.on "click", ".projects-list > li > a", (event) ->
            $el.toggleClass("closed-project-nav")
            $el.toggleClass("open-project-nav")

    link = ($scope, $el, $attrs, $ctrl) ->
        $scope.$on "$viewContentLoaded", (ctx) ->
            renderMainMenu($el, ctx.targetScope.$$childHead)

        linkProjecsNav($scope, $el, $attrs, $ctrl)

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
    "project-search": "/project/:project/search"
}

init = ($log, $navurls) ->
    $log.debug "Initialize navigation urls"
    $navurls.update(urls)

module.run(["$log", "$tgNavUrls", init])
