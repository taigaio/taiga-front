###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

HighlightedDirective = () ->
    return {
        templateUrl: "discover/components/highlighted/highlighted.html",
        scope: {
            loading: "=",
            highlighted: "=",
            orderBy: "="
        }
    }

HighlightedDirective.$inject = []

angular.module("taigaDiscover").directive("tgHighlighted", HighlightedDirective)
