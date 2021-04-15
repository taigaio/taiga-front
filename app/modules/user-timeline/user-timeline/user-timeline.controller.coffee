###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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

        @.loadTimeline()

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
