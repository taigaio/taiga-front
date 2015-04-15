###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/backlog/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

class ProfileTimelineController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$tgResources",
        "$tgAuth"
    ]

    valid_fields: ['status', 'subject', 'description', 'assigned_to', 'points', 'severity', 'priority', 'type', 'attachments', 'milestone', 'is_blocked', 'is_iocaine', 'content_diff', 'name', 'estimated_finish', 'estimated_start']

    constructor: (@rs, @auth) ->
        @timelineList = []
        @pagination = {page: 1}

    isValidField: (values) =>
        return _.some values, (value) => @valid_fields.indexOf(value) != -1

    filterValidTimelineItems: (timeline) =>
        if timeline.data.values_diff
            values = Object.keys(timeline.data.values_diff)

        if values && values.length
            if !@isValidField(values)
                return false
            else if values[0] == 'attachments' && timeline.data.values_diff.attachments.new.length == 0
                return false

        return true

    loadTimeline: () ->
        user = @auth.getUser()

        @loadingData = true

        return @rs.timeline.profile(user.id, @pagination).then (result) =>
            newTimelineList = _.filter result.data, @filterValidTimelineItems

            @timelineList = @timelineList.concat(newTimelineList)
            @pagination.page++
            @loadingData = false

angular.module("taigaProfile")
    .controller("ProfileTimeline", ProfileTimelineController)
