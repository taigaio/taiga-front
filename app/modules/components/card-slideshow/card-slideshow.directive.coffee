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
