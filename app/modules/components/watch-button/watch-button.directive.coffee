WatchButtonDirective = ->
    return {
        scope: {}
        controller: "WatchButton",
        bindToController: {
            item: "=",
            onWatch: "=",
            onUnwatch: "="
        }
        controllerAs: "vm",
        templateUrl: "components/watch-button/watch-button.html",
    }

angular.module("taigaComponents").directive("tgWatchButton", WatchButtonDirective)
