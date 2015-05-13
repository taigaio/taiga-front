taiga = @.taiga

class UserTimelineService extends taiga.Service
    @.$inject = ["tgResources"]

    constructor: (@rs) ->

    _valid_fields: [
        'status',
        'subject',
        'description',
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

    _isValidField: (values) ->
        return _.some values, (value) => @._valid_fields.indexOf(value) != -1

    _isValidEvent: (event) ->
        return event.split(".").slice(-1)[0] != 'delete'

    _filterValidTimelineItems: (timeline) ->
        if timeline.get("data")
            values = []
            values_diff = timeline.get("data").get("values_diff")

            if values_diff
                values = Object.keys(values_diff.toJS())

            if values && values.length
                if !@._isValidField(values)
                    return false
                else if values[0] == 'attachments' &&
                     values_diff.get('attachments').get('new').size == 0
                    return false

        if !@._isValidEvent(timeline.get('event_type'))
            return false

        return true

    getTimeline: (userId, page) ->
        return @rs.users.getTimeline(userId, page)
            .then (result) =>
                return result.filter (timeline) => @._filterValidTimelineItems(timeline)


    getProjectTimeline: (projectId, page) ->
        return @rs.projects.getTimeline(projectId, page)
            .then (result) =>
                return result.filter (timeline) => @._filterValidTimelineItems(timeline)

angular.module("taigaUserTimeline").service("tgUserTimelineService", UserTimelineService)
