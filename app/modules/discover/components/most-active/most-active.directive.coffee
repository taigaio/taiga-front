###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

MostActiveDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "MostActive"
        controllerAs: "vm",
        templateUrl: "discover/components/most-active/most-active.html",
        scope: {},
        link: link
    }

MostActiveDirective.$inject = []

angular.module("taigaDiscover").directive("tgMostActive", MostActiveDirective)
