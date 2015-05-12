UserTimelineItemDirective = () ->
    return {
        controllerAs: "vm"
        controller: "UserTimelineItem"
        bindToController: true
        templateUrl: "user-timeline/user-timeline-item/user-timeline-item.html"
        scope: {
            timeline: "=tgUserTimelineItem"
        }
    }

angular.module("taigaUserTimeline")
    .directive("tgUserTimelineItem", UserTimelineItemDirective)
