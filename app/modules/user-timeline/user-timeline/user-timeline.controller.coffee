###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
