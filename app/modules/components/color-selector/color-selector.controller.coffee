###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
getDefaulColorList = taiga.getDefaulColorList


class ColorSelectorController
    @.$inject = [
        "tgProjectService",
    ]

    constructor: (@projectService) ->
        @.colorList = getDefaulColorList()
        @.checkIsColorRequired()
        @.displayColorList = false

    userCanChangeColor: () ->
        return true if not @.requiredPerm
        return @projectService.hasPermission(@.requiredPerm)

    checkIsColorRequired: () ->
        if !@.isColorRequired
            @.colorList = _.dropRight(@.colorList)

    setColor: (color) ->
        @.color = color
        @.customColor = color

    resetColor: () ->
        if @.isColorRequired and not @.color
            @.color = @.initColor

    toggleColorList: () ->
        @.displayColorList = !@.displayColorList
        @.customColor = @.color
        @.resetColor()

    onSelectDropdownColor: (color) ->
        @.color = color
        @.onSelectColor({color: color})
        @.toggleColorList()

    onKeyDown: (event) ->
        if event.which == 13 # ENTER
            if @.customColor or not @.isColorRequired
                @.onSelectDropdownColor(@.customColor)
            event.preventDefault()


angular.module('taigaComponents').controller("ColorSelectorCtrl", ColorSelectorController)
