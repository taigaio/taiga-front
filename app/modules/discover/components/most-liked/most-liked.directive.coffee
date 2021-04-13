MostLikedDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.fetch()

    return {
        controller: "MostLiked"
        controllerAs: "vm",
        templateUrl: "discover/components/most-liked/most-liked.html",
        scope: {},
        link: link
    }

MostLikedDirective.$inject = []

angular.module("taigaDiscover").directive("tgMostLiked", MostLikedDirective)
