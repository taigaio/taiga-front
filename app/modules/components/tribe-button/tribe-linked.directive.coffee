TribeLinkedDirective = (configService) ->
    link = (scope, el, attrs) ->

        scope.vm = {}

        scope.vm.tribeHost = configService.config.tribeHost

        scope.vm.show = () ->
            scope.vm.open = true

        scope.vm.hide = (event) ->
            scope.vm.open = false

    directive = {
        templateUrl: "components/tribe-button/tribe-linked.html",
        scope: {
            gigTitle: "=",
            gigId: "="
        },
        link: link
    }

    return directive

TribeLinkedDirective.$inject = [
    "$tgConfig"
]

angular.module("taigaComponents").directive("tgTribeLinked", TribeLinkedDirective)
