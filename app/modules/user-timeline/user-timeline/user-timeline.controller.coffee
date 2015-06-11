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
# File: modules/profile/profile-timeline/profile-timeline.controller.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

class UserTimelineController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "tgUserTimelineService"
    ]

    min: 20
    constructor: (@userTimelineService) ->
        @.timelineList = Immutable.List()
        @.page = 1
        @.scrollDisabled = false

    loadTimeline: () ->
        @.scrollDisabled = true

        promise = null

        if @.projectId
            promise = @userTimelineService
                .getProjectTimeline(@.projectId, @.page)
        else if @.currentUser
            promise = @userTimelineService
                .getProfileTimeline(@.user.get("id"), @.page)
        else
            promise = @userTimelineService
                .getUserTimeline(@.user.get("id"), @.page)

        promise.then (list) =>
            @._timelineLoaded(list)

            if !@.scrollDisabled && @.timelineList.size < @.min
                return @.loadTimeline()

            return @.timelineList

        return promise

    _timelineLoaded: (newTimelineList) ->
        @.timelineList = @.timelineList.concat(newTimelineList)
        @.page++

        if newTimelineList.size
            @.scrollDisabled = false

angular.module("taigaUserTimeline")
    .controller("UserTimeline", UserTimelineController)
