###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

FeaturedProjectsDirective = () ->
    link = (scope, el, attrs) ->

    return {
        controller: "FeaturedProjects"
        controllerAs: "vm",
        templateUrl: "discover/components/featured-projects/featured-projects.html",
        scope: {},
        link: link
    }

FeaturedProjectsDirective.$inject = []

angular.module("taigaDiscover").directive("tgFeaturedProjects", FeaturedProjectsDirective)
