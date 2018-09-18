###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: user-timeline/user-timeline/user-timeline.service.coffee
###

taiga = @.taiga

class UserTimelineService extends taiga.Service
    @.$inject = [
        "tgResources",
        "tgUserTimelinePaginationSequenceService",
        "tgUserTimelineItemType",
        "tgUserTimelineItemTitle"
    ]

    constructor: (@rs, @userTimelinePaginationSequenceService, @userTimelineItemType, @userTimelineItemTitle) ->

    _valid_fields: [
        'status',
        'subject',
        'description_diff',
        'assigned_users',
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
        'milestone',
        'color',
        'due_date',
        'due_date_reason'
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
        {# Empty change
            check: (timeline) ->
                event = timeline.get('event_type').split(".")
                value_diff = timeline.get("data").get("value_diff")
                return event[2] == 'change' and value_diff == undefined
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

    _parseEventType: (event_type) ->
        event_type = event_type.split(".")

        return {
            section: event_type[0],
            obj: event_type[1],
            type: event_type[2]
        }

    _getTimelineObject: (timeline, event) ->
        if timeline.get('data').get(event.obj)
            return timeline.get('data').get(event.obj)

    _attachExtraInfoToTimelineEntry: (timeline, event, type) ->
        title = @userTimelineItemTitle.getTitle(timeline, event, type)

        timeline = timeline.set('title_html', title)

        timeline =  timeline.set('obj', @._getTimelineObject(timeline, event))

        if type.description
            timeline = timeline.set('description', type.description(timeline))

        if type.member
            timeline = timeline.set('member', type.member(timeline))

        if timeline.getIn(['data', 'value_diff', 'key']) == 'attachments' &&
          timeline.hasIn(['data', 'value_diff', 'value', 'new'])
            timeline = timeline.set('attachments', timeline.getIn(['data', 'value_diff', 'value', 'new']))

        return timeline

    # - create a entry per every item in the values_diff
    _parseTimeline: (response) ->
        newdata = Immutable.List()

        response.get('data').forEach (item) =>
            event = @._parseEventType(item.get('event_type'))

            data = item.get('data')
            values_diff = data.get('values_diff')

            if values_diff && values_diff.count()
                # blocked/unblocked change must be a single change
                if values_diff.has('is_blocked')
                    values_diff = Immutable.Map({'blocked': values_diff})

                if values_diff.has('milestone')
                    if event.obj == 'userstory'
                        values_diff = Immutable.Map({'moveInBacklog': values_diff})
                    else
                        values_diff = values_diff.deleteIn(['values_diff', 'milestone'])

                else if event.obj == 'milestone'
                     values_diff = Immutable.Map({'milestone': values_diff})

                values_diff.forEach (value, key) =>
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

    _addEntyAttributes: (item) ->
        event = @._parseEventType(item.get('event_type'))
        type = @userTimelineItemType.getType(item, event)

        return @._attachExtraInfoToTimelineEntry(item, event, type)

    getProfileTimeline: (userId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.users.getProfileTimeline(userId, page)
                .then (response) =>
                    return @._parseTimeline(response)

        config.map = (obj) => @._addEntyAttributes(obj)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

    getUserTimeline: (userId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.users.getUserTimeline(userId, page)
                .then (response) =>
                    return @._parseTimeline(response)

        config.map = (obj) => @._addEntyAttributes(obj)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

    getProjectTimeline: (projectId) ->
        config = {}

        config.fetch = (page) =>
            return @rs.projects.getTimeline(projectId, page)
                .then (response) => return @._parseTimeline(response)

        config.map = (obj) => @._addEntyAttributes(obj)

        config.filter = (items) =>
            return items.filterNot (item) => @._isInValidTimeline(item)

        return @userTimelinePaginationSequenceService.generate(config)

angular.module("taigaUserTimeline").service("tgUserTimelineService", UserTimelineService)
