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
# File: components/color-selector/color-selector.controller.coffee
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
