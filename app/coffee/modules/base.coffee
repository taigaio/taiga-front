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

module = angular.module("taigaBase", ["taigaLocales"])


#############################################################################
## Global Page Directive
#############################################################################

class MainTaigaController extends taiga.Controller
    @.$inject = ["$scope"]

    constructor: (@scope) ->
        @scope.mainSection = "backlog"

    setSectionName: (name) ->
        @scope.mainSection = name


MainTaigaDirective = ($log, $compile) ->
    template = _.template("""
    <h1 class="logo"><a href="" title="Home"><img src="/images/logo.png" alt="Taiga"/></a></h1>
    <ul class="main-nav">
        <li data-name="search">
            <a href="" title="Search" tg-nav="project-search:project=project.slug">
                <span class="icon icon-search"></span><span class="item">Search</span>
            </a>
        </li>
        <li data-name="backlog" tg-nav="project-backlog:project=project.slug">
            <a href="" title="Backlog" class="active">
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


    linkMainNav = ($scope, $el, $attrs, $ctrl) ->
        menuEntriesSelector = $el.find("ul.main-nav > li")
        menuEntries = _.map(menuEntriesSelector, (x) -> angular.element(x))
        menuEntriesByName = groupBy(menuEntries, (x) -> x.data("name"))

        $scope.$watch "mainSection", (sectionName) ->
            $el.find("ul.main-nav a.active").removeClass("active")
            entry = menuEntriesByName[sectionName]
            entry.find("> a").addClass("active")

    link = ($scope, $el, $attrs, $ctrl) ->
        $log.debug "Taiga main directive initialized."
        linkMainNav($scope, $el, $attrs, $ctrl)

        # WARNING: this code has traces of slighty hacky parts
        # This rerenders and compiles the navigation when ng-view
        # content loaded signal is raised using inner scope.
        $scope.$on "$viewContentLoaded", ->
            body = angular.element("body")
            wScope = body.find(".wrapper").scope()
            html = template({})
            dom = $compile(html)(wScope)

            menuDom = $el.find("nav.menu")
            menuDom.empty()
            menuDom.append(dom)

    return {
        controller: MainTaigaController
        link: link
    }


SectionMarkerDirective = ($log) ->
    link = ($scope, $el, $attrs, $ctrl) ->
        $ctrl.setSectionName($attrs.tgSectionMarker)

    return {
        require: "^tgMain"
        link: link
    }


module.directive("tgMain", ["$log", "$compile", MainTaigaDirective])
module.directive("tgSectionMarker", ["$log", SectionMarkerDirective])


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
