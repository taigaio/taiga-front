###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

DiscoverSearchListHeaderDirective = () ->
    link = (scope, el, attrs) ->

    return {
        controller: "DiscoverSearchListHeader",
        controllerAs: "vm",
        bindToController: true,
        templateUrl: "discover/components/discover-search-list-header/discover-search-list-header.html",
        scope: {
            onChange: "&",
            orderBy: "="
        },
        link: link
    }

DiscoverSearchListHeaderDirective.$inject = []

angular.module("taigaDiscover").directive("tgDiscoverSearchListHeader", DiscoverSearchListHeaderDirective)
