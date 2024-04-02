###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

MostLikedDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "MostLiked"
        controllerAs: "vm",
        templateUrl: "discover/components/most-liked/most-liked.html",
        scope: {},
        link: link
    }

MostLikedDirective.$inject = []

angular.module("taigaDiscover").directive("tgMostLiked", MostLikedDirective)
