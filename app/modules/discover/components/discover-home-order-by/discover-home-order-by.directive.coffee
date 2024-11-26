###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

DiscoverHomeOrderByDirective = () ->
    link = (scope, el, attrs) ->

    return {
        controller: "DiscoverHomeOrderBy",
        controllerAs: "vm",
        bindToController: true,
        templateUrl: "discover/components/discover-home-order-by/discover-home-order-by.html",
        scope: {
            currentOrderBy: "=orderBy",
            onChange: "&"
        },
        link: link
    }

DiscoverHomeOrderByDirective.$inject = []

angular.module("taigaDiscover").directive("tgDiscoverHomeOrderBy", DiscoverHomeOrderByDirective)
