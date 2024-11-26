###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
timeout = @.taiga.timeout
cancelTimeout = @.taiga.cancelTimeout

#############################################################################
## Swimlane Selector
#############################################################################

WipLimitSelector = ($timeout) ->

    link = (scope, el, attrs) ->

        scope.displayWipLimitSelector = false

        scope.toggleWipSelectorVisibility = () ->
            scope.displayWipLimitSelector = !scope.displayWipLimitSelector

    return {
        link: link,
        scope: {}
        templateUrl: "components/wip-limit-selector/wip-limit-selector.html",
        controller: "ProjectSwimlanesWipLimit",
        bindToController: {
            status: '=',
        }
        controllerAs: "vm",
    }

angular.module('taigaComponents').directive("tgWipLimitSelector", [WipLimitSelector])
