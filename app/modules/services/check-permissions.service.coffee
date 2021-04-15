###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

class CheckPermissionsService
    @.$inject = [
        "tgProjectService"
    ]

    constructor: (@projectService) ->

    check: (permission) ->
        return false if !@projectService.project

        return @projectService.project.get('my_permissions').indexOf(permission) != -1

angular.module("taigaCommon").service("tgCheckPermissionsService", CheckPermissionsService)
