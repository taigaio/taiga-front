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
# File: color-selector.directive.coffee
###

module = angular.module('taigaCommon')

ColorSelectorDirective = ($timeout) ->
    link = (scope, el) ->
        timeout = null

        cancel = () ->
            $timeout.cancel(timeout)
            timeout = null

        close = () ->
            return if timeout

            timeout = $timeout (() ->
                scope.vm.displaycolorList = false
            ), 400

        el.find('.color-selector')
            .mouseenter(cancel)
            .mouseleave(close)

        el.find('.color-selector-dropdown')
            .mouseenter(cancel)
            .mouseleave(close)

    return {
        link: link,
        scope:{
            onSelectColor: "&",
            color: "="
        },
        templateUrl:"components/tags/color-selector/color-selector.html",
        controller: "ColorSelectorCtrl",
        controllerAs: "vm",
        bindToController: true
    }

ColorSelectorDirective.$inject = [
    "$timeout"
]

module.directive("tgColorSelector", ColorSelectorDirective)
