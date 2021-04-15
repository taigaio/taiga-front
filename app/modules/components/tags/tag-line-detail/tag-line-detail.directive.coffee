###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaCommon')

TagLineDirective = () ->
    return {
        scope: {
            item: "=",
            permissions: "@",
            project: "="
        },
        templateUrl:"components/tags/tag-line-detail/tag-line-detail.html",
        controller: "TagLineCtrl",
        controllerAs: "vm",
        bindToController: true
    }

module.directive("tgTagLine", TagLineDirective)
