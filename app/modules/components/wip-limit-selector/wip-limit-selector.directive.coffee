###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
