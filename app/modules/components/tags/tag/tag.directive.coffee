###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module('taigaCommon')

TagDirective = () ->
    return {
        templateUrl:"components/tags/tag/tag.html",
        scope: {
            tag: "<",
            loadingRemoveTag: "<",
            onDeleteTag: "&",
            hasPermissions: "<"
        },
    }

module.directive("tgTag", TagDirective)
