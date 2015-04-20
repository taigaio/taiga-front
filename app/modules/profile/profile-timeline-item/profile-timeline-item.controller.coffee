class ProfileTimelineItemController
    @.$inject = [
        "$scope",
        "$sce",
        "tgProfileTimelineItemType",
        "tgProfileTimelineItemTitle"
    ]

    constructor: (@scope, @sce, @profileTimelineItemType, @profileTimelineItemTitle) ->
        event = @parseEventType(@scope.vm.timeline.event_type)
        type = @profileTimelineItemType.getType(@scope.vm.timeline, event)

        @.activity = {}

        @.activity.user = @scope.vm.timeline.data.user
        @.activity.project = @scope.vm.timeline.data.project
        @.activity.sprint = @scope.vm.timeline.data.milestone
        @.activity.title = @profileTimelineItemTitle.getTitle(@scope.vm.timeline, event, type)
        @.activity.created_formated = moment(@scope.vm.timeline.created).fromNow()

        if type.description
            @.activity.description = @sce.trustAsHtml(type.description(@scope.vm.timeline))

        if type.member
            @.activity.member = type.member(@scope.vm.timeline)

        if @scope.vm.timeline.data.values_diff?.attachments
            @.activity.attachments = @scope.vm.timeline.data.values_diff.attachments.new

    parseEventType: (event_type) ->
        event_type = event_type.split(".")

        return {
            section: event_type[0],
            obj: event_type[1],
            type: event_type[2]
        }

angular.module("taigaProfile")
    .controller("ProfileTimelineItem", ProfileTimelineItemController)
