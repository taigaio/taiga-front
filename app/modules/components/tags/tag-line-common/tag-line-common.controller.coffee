###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
