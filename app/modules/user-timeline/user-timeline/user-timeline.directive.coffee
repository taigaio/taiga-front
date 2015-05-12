UserTimelineDirective = ->
    return {
        templateUrl: "user-timeline/user-timeline/user-timeline.html",
        controller: "UserTimeline",
        controllerAs: "vm",
        scope: {}
    }

angular.module("taigaProfile").directive("tgUserTimeline", UserTimelineDirective)
