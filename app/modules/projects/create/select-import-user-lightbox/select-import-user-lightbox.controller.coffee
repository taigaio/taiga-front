###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
