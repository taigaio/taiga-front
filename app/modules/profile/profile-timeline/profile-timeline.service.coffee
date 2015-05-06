taiga = @.taiga

class ProfileTimelineService extends taiga.Service
    @.$inject = ["$tgResources"]

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

    _isValidField: (values) =>
        return _.some values, (value) => @._valid_fields.indexOf(value) != -1

    _filterValidTimelineItems: (timeline) =>
        if timeline.data.values_diff
            values = Object.keys(timeline.data.values_diff)

        if values && values.length
            if !@._isValidField(values)
                return false
            else if values[0] == 'attachments' &&
                 timeline.data.values_diff.attachments.new.length == 0
                return false

        return true

    getTimeline: (userId, page) ->
        return @rs.timeline.profile(userId, page)
            .then (result) =>
                newTimelineList = _.filter result.data, @._filterValidTimelineItems

                return Immutable.fromJS(newTimelineList)


angular.module("taigaProjects").service("tgProfileTimelineService", ProfileTimelineService)
