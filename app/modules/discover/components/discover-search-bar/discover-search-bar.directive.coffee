###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

DiscoverSearchBarDirective = () ->
    link = (scope, el, attrs, ctrl) ->

    return {
        controller: "DiscoverSearchBar",
        controllerAs: "vm"
        templateUrl: 'discover/components/discover-search-bar/discover-search-bar.html',
        bindToController: true,
        scope: {
            q: "=",
            filter: "=",
            onChange: "&"
        },
        compile: (element, attrs) ->
            if !attrs.q
                attrs.q = ''
        link: link
    }

DiscoverSearchBarDirective.$inject = []

angular.module('taigaDiscover').directive('tgDiscoverSearchBar', DiscoverSearchBarDirective)
