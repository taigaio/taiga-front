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
# File: user-timeline/user-timeline/user-timeline.controller.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

class UserTimelineController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "tgUserTimelineService"
    ]

    constructor: (@userTimelineService) ->
        @.timelineList = Immutable.List()
        @.scrollDisabled = false

        @.timeline = null

        if @.projectId
            @.timeline = @userTimelineService.getProjectTimeline(@.projectId)
        else if @.currentUser
            @.timeline = @userTimelineService.getProfileTimeline(@.user.get("id"))
        else
            @.timeline = @userTimelineService.getUserTimeline(@.user.get("id"))

    loadTimeline: () ->
        @.scrollDisabled = true

        return @.timeline
            .next()
            .then (response) =>
                @.timelineList = @.timelineList.concat(response.get("items"))

                if response.get("next")
                    @.scrollDisabled = false

                return @.timelineList

angular.module("taigaUserTimeline")
    .controller("UserTimeline", UserTimelineController)
