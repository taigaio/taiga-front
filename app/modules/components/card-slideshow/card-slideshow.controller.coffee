###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class CardSlideshowController
    @.$inject = []

    constructor: () ->
        @.index = 0

    next: () ->
        @.index++

        if @.index >= @.images.size
            @.index = 0

    previous: () ->
        @.index--

        if @.index < 0
            @.index = @.images.size - 1

angular.module('taigaComponents').controller('CardSlideshow', CardSlideshowController)
