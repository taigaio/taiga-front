###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class SelectImportUserLightboxCtrl
    @.$inject = []

    constructor: () ->

    start: () ->
        @.mode = 'search'
        @.invalid = false

    assignUser: () ->
        @.onSelectUser({user: @.user, taigaUser: @.userEmail})

    selectUser: (taigaUser) ->
        @.onSelectUser({user: @.user, taigaUser: Immutable.fromJS(taigaUser)})

angular.module('taigaProjects').controller('SelectImportUserLightboxCtrl', SelectImportUserLightboxCtrl)
