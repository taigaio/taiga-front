###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
