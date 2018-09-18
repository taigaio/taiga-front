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
# File: projects/create/create-project.controller.coffee
###

class CreateProjectController
    @.$inject = [
        "tgAppMetaService",
        "$translate",
        "tgProjectService",
        "$location",
        "$tgAuth"
    ]

    constructor: (@appMetaService, @translate, @projectService, @location, @authService) ->
        taiga.defineImmutableProperty @, "project", () => return @projectService.project

        @appMetaService.setfn @._setMeta.bind(this)

        @authService.refresh()

        @.displayScrumDesc = false
        @.displayKanbanDesc = false

    _setMeta: () ->
        return null if !@.project

        ctx = {projectName: @.project.get("name")}

        return {
            title: @translate.instant("PROJECT.PAGE_TITLE", ctx)
            description: @.project.get("description")
        }

    displayHelp: (type, $event) ->
        $event.stopPropagation()
        $event.preventDefault()

        if type == 'scrum'
            @.displayScrumDesc = !@.displayScrumDesc
        if type == 'kanban'
            @.displayKanbanDesc = !@.displayKanbanDesc


angular.module("taigaProjects").controller("CreateProjectCtrl", CreateProjectController)
