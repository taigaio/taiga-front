module = angular.module("taigaComponents")

cardDirective = () ->
    return {
        controller: "Card",
        controllerAs: "vm",
        templateUrl: "components/card/card.html",
        bindToController: {
            onToggleFold: "&",
            onClickAssignedTo: "&",
            onClickEdit: "&",
            onClickRemove: "&",
            onClickDelete: "&",
            project: "<",
            item: "<",
            zoom: "<",
            zoomLevel: "<",
            archived: "<",
            inViewPort: "<",
            folded: "<"
            type: "@"
        }
    }

module.directive('tgCard', cardDirective)
