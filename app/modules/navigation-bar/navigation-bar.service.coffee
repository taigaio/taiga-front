###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class NavigationBarService extends taiga.Service

    constructor: ->
        @.disableHeader()

    enableHeader: ->
        @.enabledHeader = true

    disableHeader:  ->
        @.enabledHeader = false

    isEnabledHeader: ->
        return @.enabledHeader

angular.module("taigaNavigationBar").service("tgNavigationBarService", NavigationBarService)
