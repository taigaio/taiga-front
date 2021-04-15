###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
