HighlightedDirective = () ->
    return {
        templateUrl: "discover/components/highlighted/highlighted.html",
        scope: {
            loading: "=",
            highlighted: "=",
            orderBy: "="
        }
    }

HighlightedDirective.$inject = []

angular.module("taigaDiscover").directive("tgHighlighted", HighlightedDirective)
