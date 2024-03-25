###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
