###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProjectLogoService
    constructor: () ->
        IMAGES = [
            "#{window._version}/images/project-logos/project-logo-01.png"
            "#{window._version}/images/project-logos/project-logo-02.png"
            "#{window._version}/images/project-logos/project-logo-03.png"
            "#{window._version}/images/project-logos/project-logo-04.png"
            "#{window._version}/images/project-logos/project-logo-05.png"
        ]

        COLORS = [
            "rgba( 153,  214, 220, 1 )"
            "rgba( 213,  156,  156, 1 )"
            "rgba( 214, 161, 212,  1 )"
            "rgba( 164, 162, 219, 1 )"
            "rgba( 152, 224, 168,  1 )"
        ]

        @.logos = _.cartesianProduct(IMAGES, COLORS)

    getDefaultProjectLogo: (slug, id) ->
        key = "#{slug}-#{id}"
        idx = murmurhash3_32_gc(key, 42) %% @.logos.length
        logo = @.logos[idx]

        return { src: logo[0], color: logo[1] }

angular.module("taigaCommon").service("tgProjectLogoService", ProjectLogoService)
