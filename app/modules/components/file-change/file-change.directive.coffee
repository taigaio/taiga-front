FileChangeDirective = ($parse) ->
    link = (scope, el, attrs, ctrl) ->
        eventAttr = $parse(attrs.tgFileChange)

        el.on 'change', (event) ->
            scope.$apply () -> eventAttr(scope, {files: event.currentTarget.files})

        scope.$on "$destroy", -> el.off()

    return {
        restrict: "A",
        link: link
    }

FileChangeDirective.$inject = [
    "$parse"
]

angular.module("taigaComponents").directive("tgFileChange", FileChangeDirective)
