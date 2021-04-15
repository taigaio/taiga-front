###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaComponents")

cardSlideshowDirective = () ->
    return {
        controller: "CardSlideshow",
        templateUrl: "components/card-slideshow/card-slideshow.html",
        bindToController: true,
        controllerAs: "vm",
        scope: {
            images: "="
        }
    }

module.directive('tgCardSlideshow', cardSlideshowDirective)
