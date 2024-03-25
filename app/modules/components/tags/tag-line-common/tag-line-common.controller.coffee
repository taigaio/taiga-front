###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
        hasPermissions = @tagLineService.checkPermissions(@.project.my_permissions, @.permissions)
        return hasPermissions

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
