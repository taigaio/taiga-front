WatchProjectButtonDirective = ->
    return {
        scope: {}
        controller: "WatchProjectButton",
        bindToController: {
            project: "="
        }
        controllerAs: "vm",
        templateUrl: "projects/components/watch-project-button/watch-project-button.html",
    }

angular.module("taigaProjects").directive("tgWatchProjectButton", WatchProjectButtonDirective)
