###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
