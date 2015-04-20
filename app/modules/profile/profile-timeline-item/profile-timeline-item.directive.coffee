ProfileTimelineItemDirective = () ->
    return {
        controllerAs: "vm"
        controller: "ProfileTimelineItem"
        bindToController: true
        templateUrl: "profile/profile-timeline-item/profile-timeline-item.html"
        scope: {
            timeline: "=tgProfileTimelineItem"
        }
    }

angular.module("taigaProfile")
    .directive("tgProfileTimelineItem", ProfileTimelineItemDirective)
