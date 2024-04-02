###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
