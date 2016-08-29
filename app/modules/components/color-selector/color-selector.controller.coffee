###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: color-selector.controller.coffee
###

taiga = @.taiga
getDefaulColorList = taiga.getDefaulColorList


class ColorSelectorController
    constructor: () ->
        @.colorList = getDefaulColorList()

        if @.initColor
            @.color = @.initColor

        @.displaycolorList = false

    toggleColorList: () ->
        @.displaycolorList = !@.displaycolorList

        if @.isRequired and not @.color
            @.color = @.initColor

    onSelectDropdownColor: (color) ->
        @.color = color
        @.onSelectColor({color: color})
        @.toggleColorList()

    onKeyDown: (event) ->
        if event.which == 13 # ENTER
            event.stopPropagation()
            if @.color or not @.isRequired
                @.onSelectDropdownColor(@.color)


angular.module('taigaComponents').controller("ColorSelectorCtrl", ColorSelectorController)
