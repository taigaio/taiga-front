###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: tag-line.controller.coffee
###

trim = @.taiga.trim

module = angular.module('taigaCommon')

class TagLineCommonController

    @.$inject = [
        "tgTagLineService"
    ]

    constructor: (@tagLineService) ->
        @.disableColorSelection = false
        @.newTag = {name: "", color: null}
        @.colorArray = []
        @.addTag = false

    checkPermissions: () ->
        return @tagLineService.checkPermissions(@.project.my_permissions, @.permissions)

    _createColorsArray: (projectTagColors) ->
        @.colorArray =  @tagLineService.createColorsArray(projectTagColors)

    displayTagInput: () ->
        @.addTag = true

    addNewTag: (name, color) ->
        @.newTag.name = ""
        @.newTag.color = null

        return if not name.length

        if @.disableColorSelection
            @.onAddTag({name: name, color: color}) if name.length
        else
            if @.project.tags_colors[name]
                color = @.project.tags_colors[name]
            @.onAddTag({name: name, color: color})

    selectColor: (color) ->
        @.newTag.color = color

module.controller("TagLineCommonCtrl", TagLineCommonController)
