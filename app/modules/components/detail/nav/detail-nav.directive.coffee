###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaBase')

DetailNavDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        scope.$watch "vm.item", (value) ->
            return if not value
            ctrl._checkNav()

    return {
        link: link,
        controller: "DetailNavCtrl",
        bindToController: true,
        scope: {
            item: "="
        },
        controllerAs: "vm",
        templateUrl:"components/detail/nav/detail-nav.html"
    }

module.directive("tgDetailNav", DetailNavDirective)
