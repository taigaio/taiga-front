###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
