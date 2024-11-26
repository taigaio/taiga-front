###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
