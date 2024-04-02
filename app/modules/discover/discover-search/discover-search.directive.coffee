###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

DiscoverSearchDirective = () ->
    link = (scope, element, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "DiscoverSearch",
        controllerAs: "vm"
        link: link
    }

DiscoverSearchDirective.$inject = []

angular.module("taigaDiscover").directive("tgDiscoverSearch", DiscoverSearchDirective)
