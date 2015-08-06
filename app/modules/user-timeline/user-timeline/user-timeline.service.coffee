taiga = @.taiga

class UserTimelineService extends taiga.Service
    @.$inject = ["tgResources", "tgUserTimelinePaginationSequenceService"]

    constructor: (@rs, @userTimelinePaginationSequenceService) ->

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
        'is_iocaine',
        'content_diff',
        'name',
        'estimated_finish',
        'estimated_start',
        # customs
        'blocked',
        'moveInBacklog',
        'milestone'
    ]

    _invalid: [
        {# Items with only invalid fields
            check: (timeline) ->
                value_diff = timeline.get("data").get("value_diff")

                if value_diff
                    fieldKey = value_diff.get('key')

                    if @._valid_fields.indexOf(fieldKey) == -1
                        return true
                    else if fieldKey == 'attachments' &&
                         value_diff.get('value').get('new').size == 0
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
                value_diff = timeline.get("data").get("value_diff")

                if value_diff &&
                     event[1] == "task" &&
                     event[2] == "change" &&
                     value_diff.get("key") == "milestone"
                    return timeline.get("data").get("value_diff").get("value")

                return false
        }
    ]

    _isInValidTimeline: (timeline) ->
        return _.some @._invalid, (invalid) =>
            return invalid.check.call(this, timeline)

    # create a entry per every item in the values_diff
    _splitChanges: (response) ->
        newdata = Immutable.List()

        response.get('data').forEach (item) ->
            event_type = item.get('event_type').split(".")

            data = item.get('data')
            values_diff = data.get('values_diff')

            if values_diff && values_diff.count()
                # blocked/unblocked change must be a single change
                if values_diff.has('is_blocked')
                    values_diff = Immutable.Map({'blocked': values_diff})

                if values_diff.has('milestone')
                    values_diff = Immutable.Map({'moveInBacklog': values_diff})
                else if event_type[1] == 'milestone'
                     values_diff = Immutable.Map({'milestone': values_diff})

                values_diff.forEach (value, key) ->
                    obj = Immutable.Map({
                        key: key,
                        value: value
                    })

                    newItem = item.setIn(['data', 'value_diff'], obj)
                    newItem = newItem.deleteIn(['data', 'values_diff'])
                    newdata = newdata.push(newItem)
            else
                newItem = item.deleteIn(['data', 'values_diff'])
                newdata = newdata.push(newItem)

        return response.set('data', newdata)

    getProfileTimeline: (userId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.users.getProfileTimeline(userId, page)
                .then (response) =>
                    return @._splitChanges(response)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

    getUserTimeline: (userId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.users.getUserTimeline(userId, page)
                .then (response) =>
                    return @._splitChanges(response)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

    getProjectTimeline: (projectId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.projects.getTimeline(projectId, page)
                .then (response) => return @._splitChanges(response)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

angular.module("taigaUserTimeline").service("tgUserTimelineService", UserTimelineService)
