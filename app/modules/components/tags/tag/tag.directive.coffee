###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
