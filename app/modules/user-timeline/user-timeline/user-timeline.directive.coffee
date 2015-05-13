UserTimelineDirective = ->
    return {
        templateUrl: "user-timeline/user-timeline/user-timeline.html",
        controller: "UserTimeline",
        controllerAs: "vm",
        scope: {
            projectId: "=projectid",
            userId: "=userid"
        },
        bindToController: true
    }

angular.module("taigaProfile").directive("tgUserTimeline", UserTimelineDirective)
