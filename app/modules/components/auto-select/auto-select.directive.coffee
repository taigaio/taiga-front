AutoSelectDirective = ($timeout) ->
    return {
        link: (scope, elm) ->
            $timeout () -> elm[0].select()
    }

AutoSelectDirective.$inject = [
    '$timeout'
]

angular.module("taigaComponents").directive("tgAutoSelect", AutoSelectDirective)
