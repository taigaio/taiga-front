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
# File: projects/project/project.controller.coffee
###

class ProjectController
    @.$inject = [
        "$routeParams",
        "tgAppMetaService",
        "$tgAuth",
        "$translate",
        "tgProjectService"
    ]

    constructor: (@routeParams, @appMetaService, @auth, @translate, @projectService) ->
        @.user = @auth.userData

        taiga.defineImmutableProperty @, "project", () => return @projectService.project
        taiga.defineImmutableProperty @, "members", () => return @projectService.activeMembers

        @appMetaService.setfn @._setMeta.bind(this)

    _setMeta: ()->
        return null if !@.project

        ctx = {projectName: @.project.get("name")}

        return {
            title: @translate.instant("PROJECT.PAGE_TITLE", ctx)
            description: @.project.get("description")
        }

angular.module("taigaProjects").controller("Project", ProjectController)
