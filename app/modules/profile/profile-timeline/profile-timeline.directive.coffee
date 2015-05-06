ProfileTimelineDirective = ->
    return {
        templateUrl: "profile/profile-timeline/profile-timeline.html",
        controller: "ProfileTimeline",
        controllerAs: "vm",
        scope: {}
    }

angular.module("taigaProfile").directive("tgProfileTimeline", ProfileTimelineDirective)
