###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: navigation-bar/dropdown-project-list/dropdown-project-list.directive.coffee
###

DropdownProjectListDirective = (currentUserService, projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))

        scope.vm.newProject = ->
            projectsService.newProject()

    directive = {
        templateUrl: "navigation-bar/dropdown-project-list/dropdown-project-list.html"
        scope: {}
        link: link
    }

    return directive

DropdownProjectListDirective.$inject = [
    "tgCurrentUserService",
    "tgProjectsService"
]

angular.module("taigaNavigationBar").directive("tgDropdownProjectList", DropdownProjectListDirective)
