###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
