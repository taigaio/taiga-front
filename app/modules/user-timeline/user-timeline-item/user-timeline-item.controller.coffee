class UserTimelineItemController
    @.$inject = [
        "tgUserTimelineItemType",
        "tgUserTimelineItemTitle"
    ]

    constructor: (@userTimelineItemType, @userTimelineItemTitle) ->
        event = @.parseEventType(@.timeline.get('event_type'))
        type = @userTimelineItemType.getType(@.timeline, event)

        title = @userTimelineItemTitle.getTitle(@.timeline, event, type)

        @.timeline = @.timeline.set('title_html', title)

        @.timeline =  @.timeline.set('obj', @.getObject(@.timeline, event))

        if type.description
            @.timeline = @.timeline.set('description', type.description(@.timeline))

        if type.member
            @.timeline = @.timeline.set('member', type.member(@.timeline))

        if @.timeline.getIn(['data', 'value_diff', 'key']) == 'attachments' &&
          @.timeline.hasIn(['data', 'value_diff', 'value', 'new'])
            @.timeline = @.timeline.set('attachments', @.timeline.getIn(['data', 'value_diff', 'value', 'new']))

    getObject: (timeline, event) ->
        if timeline.get('data').get(event.obj)
            return timeline.get('data').get(event.obj)

    parseEventType: (event_type) ->
        event_type = event_type.split(".")

        return {
            section: event_type[0],
            obj: event_type[1],
            type: event_type[2]
        }

angular.module("taigaUserTimeline")
    .controller("UserTimelineItem", UserTimelineItemController)
