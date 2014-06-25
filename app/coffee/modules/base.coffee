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


MainTaigaDirective = ($log) ->
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


module.directive("tgMain", ["$log", MainTaigaDirective])
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
}

init = ($log, $navurls) ->
    $log.debug "Initialize navigation urls"
    $navurls.update(urls)

module.run(["$log", "$tgNavUrls", init])
