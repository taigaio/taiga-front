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
