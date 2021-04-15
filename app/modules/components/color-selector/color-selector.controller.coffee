###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
