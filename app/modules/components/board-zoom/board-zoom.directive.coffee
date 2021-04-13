BoardZoomDirective = () ->
    return {
        scope: {
            levels: "=",
            value: "="
        },
        templateUrl: 'components/board-zoom/board-zoom.html'
    }

angular.module('taigaComponents').directive("tgBoardZoom", [BoardZoomDirective])
