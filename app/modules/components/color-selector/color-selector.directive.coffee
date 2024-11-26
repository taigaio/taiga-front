###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
