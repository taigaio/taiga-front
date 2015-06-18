taiga = @.taiga

class UserTimelineService extends taiga.Service
    @.$inject = ["tgResources", "tgUserTimelinePaginationSequenceService"]

    constructor: (@rs, @userTimelinePaginationSequenceService) ->

    _invalid: [
        {# Items with only invalid fields
            check: (timeline) ->
                values_diff = timeline.get("data").get("values_diff")

                if values_diff
                    values = Object.keys(values_diff.toJS())

                if values && values.length
                    if _.every(values, (value) => @._valid_fields.indexOf(value) == -1)
                        return true
                    else if values[0] == 'attachments' &&
                         values_diff.get('attachments').get('new').size == 0
                        return true

                return false
        },
        {# Deleted
            check: (timeline) ->
                event = timeline.get('event_type').split(".")
                return event[2] == 'delete'
        },
        {# Project change
            check: (timeline) ->
                event = timeline.get('event_type').split(".")
                return event[1] == 'project' && event[2] == 'change'
        },
        {# Comment deleted
            check: (timeline) ->
                return !!timeline.get("data").get("comment_deleted")
        },
        {# Task milestone
            check: (timeline) ->
                event = timeline.get('event_type').split(".")

                if event[1] == "task" && event[2] == "change"
                    return timeline.get("data").get("values_diff").get("milestone")

                return false
        }
    ]

    _valid_fields: [
        'status',
        'subject',
        'description_diff',
        'assigned_to',
        'points',
        'severity',
        'priority',
        'type',
        'attachments',
        'milestone',
        'is_blocked',
        'is_iocaine',
        'content_diff',
        'name',
        'estimated_finish',
        'estimated_start'
    ]

    _isInValidTimeline: (timeline) ->
        return _.some @._invalid, (invalid) =>
            return invalid.check.call(this, timeline)

    getProfileTimeline: (userId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.users.getProfileTimeline(userId, page)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

    getUserTimeline: (userId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.users.getUserTimeline(userId, page)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

    getProjectTimeline: (projectId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.projects.getTimeline(projectId, page)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

angular.module("taigaUserTimeline").service("tgUserTimelineService", UserTimelineService)
