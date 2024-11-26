###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class FeaturedProjectsController
    @.$inject = [
        "tgDiscoverProjectsService"
    ]

    constructor: (@discoverProjectsService) ->
        taiga.defineImmutableProperty @, "featured", () => return @discoverProjectsService.featured

        @discoverProjectsService.fetchFeatured()

angular.module("taigaDiscover").controller("FeaturedProjects", FeaturedProjectsController)
