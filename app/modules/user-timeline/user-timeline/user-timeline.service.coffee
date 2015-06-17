taiga = @.taiga

class UserTimelineService extends taiga.Service
    @.$inject = ["tgResources", "tgPaginationSequenceService"]

    constructor: (@rs, @paginationSequenceService) ->

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

    getProfileTimeline: (userId, page) ->
        return @rs.users.getProfileTimeline(userId, page)
            .then (result) =>
                return result.filterNot (timeline) =>
                    return @._isInValidTimeline(timeline)

    getUserTimeline: (userId, page) ->
        return @rs.users.getUserTimeline(userId, page)
            .then (result) =>
                return result.filterNot (timeline) =>
                    return @._isInValidTimeline(timeline)

    getProjectTimeline: (projectId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.projects.getTimeline(projectId, page)

        config.filter = (result) =>
            return result.filterNot (item) => @._isInValidTimeline(item)

        config.items = 20

        return @paginationSequenceService(config)

        # return @rs.projects.getTimeline(projectId, page)
        #     .then (result) =>
        #         timeline = Immutable.Map()

        #         data = result.get("data").filterNot (item) =>
        #             return @._isInValidTimeline(item)

        #         timeline = timeline.set("data", data)
        #         timeline = timeline.set("next", !!result.get("headers")("x-pagination-next"))

        #         return timeline

angular.module("taigaUserTimeline").service("tgUserTimelineService", UserTimelineService)

PaginationSequence = () ->
    return (config) ->
        page = 1

        obj = {}

        obj.next = () ->
            config.fetch(page).then (response) ->
                page++

                data = response.get("data")

                if config.filter
                    data = config.filter(response.get("data"))

                if data.size < config.items && response.get("next")
                    return obj.next()

                return data

        return obj

angular.module("taigaCommon").factory("tgPaginationSequenceService", PaginationSequence)


PaginateResponse = () ->
    return (result) ->
        paginateResponse = Immutable.Map()

        paginateResponse = paginateResponse.set("data", result.get("data"))
        paginateResponse = paginateResponse.set("next", !!result.get("headers")("x-pagination-next"))
        paginateResponse = paginateResponse.set("prev", !!result.get("headers")("x-pagination-prev"))
        paginateResponse = paginateResponse.set("current", result.get("headers")("x-pagination-current"))
        paginateResponse = paginateResponse.set("count", result.get("headers")("x-pagination-count"))

        return paginateResponse

angular.module("taigaCommon").factory("tgPaginateResponseService", PaginateResponse)
