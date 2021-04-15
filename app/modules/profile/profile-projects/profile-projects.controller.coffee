###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProfileProjectsController
    @.$inject = [
        "tgProjectsService",
        "tgUserService"
    ]

    constructor: (@projectsService, @userService) ->

    loadProjects: () ->
        @projectsService.getProjectsByUserId(@.user.get("id"))
            .then (projects) =>
                return @userService.attachUserContactsToProjects(@.user.get("id"), projects)
            .then (projects) =>
                @.projects = projects

angular.module("taigaProfile")
    .controller("ProfileProjects", ProfileProjectsController)
