class ProfileTimelineItemController
    @.$inject = [
        "$sce",
        "tgProfileTimelineItemType",
        "tgProfileTimelineItemTitle"
    ]

    constructor: (@sce, @profileTimelineItemType, @profileTimelineItemTitle) ->
        timeline = @.timeline
        event = @.parseEventType(timeline.event_type)
        type = @profileTimelineItemType.getType(timeline, event)

        @.activity = {}

        @.activity.user = timeline.data.user
        @.activity.project = timeline.data.project
        @.activity.sprint = timeline.data.milestone
        @.activity.title = @profileTimelineItemTitle.getTitle(timeline, event, type)
        @.activity.created_formated = moment(timeline.created).fromNow()
        @.activity.obj =  @.getObject(timeline, event)

        if type.description
            @.activity.description = @sce.trustAsHtml(type.description(timeline))

        if type.member
            @.activity.member = type.member(timeline)

        if timeline.data.values_diff?.attachments
            @.activity.attachments = timeline.data.values_diff.attachments.new

    parseEventType: (event_type) ->
        event_type = event_type.split(".")

        return {
            section: event_type[0],
            obj: event_type[1],
            type: event_type[2]
        }

    getObject: (timeline, event) ->
        if timeline.data[event.obj]
            return timeline.data[event.obj]

angular.module("taigaProfile")
    .controller("ProfileTimelineItem", ProfileTimelineItemController)
