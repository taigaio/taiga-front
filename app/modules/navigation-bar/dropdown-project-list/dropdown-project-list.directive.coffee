###
# Copyright (C) 2014-present Taiga Agile LLC
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

DropdownProjectListDirective = (rootScope, currentUserService, projectsService, projectService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("recents"))

        taiga.defineImmutableProperty(scope.vm, "currentProject",
            () ->
                if projectService.project
                    return projectService.project.get('id')

                return null
        )

        scope.vm.newProject = ->
            projectsService.newProject()

        updateLinks = ->
            el.find(".dropdown-project-list ul li a").data("fullUrl", "")

        rootScope.$on("dropdown-project-list:updated", updateLinks)

    directive = {
        templateUrl: "navigation-bar/dropdown-project-list/dropdown-project-list.html"
        scope: {
            active: "="
        }
        link: link
    }

    return directive

DropdownProjectListDirective.$inject = [
    "$rootScope",
    "tgCurrentUserService",
    "tgProjectsService",
    "tgProjectService"
]

angular.module("taigaNavigationBar").directive("tgDropdownProjectList", DropdownProjectListDirective)
