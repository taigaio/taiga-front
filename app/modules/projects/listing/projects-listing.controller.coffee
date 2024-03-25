###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class ProjectsListingController
    @.$inject = [
        "tgCurrentUserService"
    ]

    constructor: (@currentUserService) ->
        taiga.defineImmutableProperty(@, "projects", () => @currentUserService.projects.get("all"))

angular.module("taigaProjects").controller("ProjectsListing", ProjectsListingController)
