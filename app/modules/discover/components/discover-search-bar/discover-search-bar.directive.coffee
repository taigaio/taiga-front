###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
