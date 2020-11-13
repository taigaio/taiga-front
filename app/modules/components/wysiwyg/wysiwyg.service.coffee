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
# File: components/wysiwyg/wysiwyg.service.coffee
###

class WysiwygService
    @.$inject = [
        "tgProjectService",
    ]

    constructor: (@projectService) ->
        @.projectDataConversion = {}

    getMarkdown: (html) ->
        projectId = @projectService.project.get('id')

        if !@.projectDataConversion[projectId]
            @.dataConversion = window.angularDataConversion()
            @.dataConversion.setUp(@projectService.project.get('slug'))
            @.projectDataConversion[projectId] = @.dataConversion

        return @.projectDataConversion[projectId].toMarkdown(html)

    getHTML: (text) ->
        return "" if !text || !text.length

        projectId = @projectService.project.get('id')

        if !@.projectDataConversion[projectId]
            @.dataConversion = window.angularDataConversion()
            @.dataConversion.setUp(@projectService.project.get('slug'))
            @.projectDataConversion[projectId] = @.dataConversion

        return @.projectDataConversion[projectId].toHtml(text)

angular.module("taigaComponents")
    .service("tgWysiwygService", WysiwygService)
