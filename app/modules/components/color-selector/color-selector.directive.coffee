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
# File: components/color-selector/color-selector.directive.coffee
###

bindOnce = @.taiga.bindOnce

ColorSelectorDirective = ($timeout) ->
    link = (scope, el, attrs, ctrl) ->
        # Animation
        _timeout = null

        cancel = () ->
            $timeout.cancel(_timeout)
            _timeout = null

        close = () ->
            return if _timeout

            _timeout = $timeout (() ->
                ctrl.displayColorList = false
                ctrl.resetColor()
            ), 400

        el.find('.color-selector')
            .mouseenter(cancel)
            .mouseleave(close)

        el.find('.color-selector-dropdown')
            .mouseenter(cancel)
            .mouseleave(close)

        scope.$watch 'vm.initColor', (color) ->
            # We can't just bind once because sometimes the initial color is reset from the outside
            ctrl.setColor(color)

    return {
        link: link,
        templateUrl:"components/color-selector/color-selector.html",
        controller: "ColorSelectorCtrl",
        controllerAs: "vm",
        bindToController: {
            isColorRequired: "=",
            onSelectColor: "&",
            initColor: "=",
            requiredPerm: "@"
        },
        scope: {},
    }


ColorSelectorDirective.$inject = [
    "$timeout"
]

angular.module('taigaComponents').directive("tgColorSelector", ColorSelectorDirective)
