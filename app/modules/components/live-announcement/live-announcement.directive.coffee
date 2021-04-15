###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

LiveAnnouncementDirective = (liveAnnouncementService) ->
    link = (scope, el, attrs) ->

    return {
        restrict: "AE",
        scope: {},
        controllerAs: 'vm',
        controller: () ->
            this.close = () ->
                liveAnnouncementService.open = false

            Object.defineProperties(this, {
                open: {
                    get: () -> return liveAnnouncementService.open
                },
                title: {
                    get: () -> return liveAnnouncementService.title
                },
                desc: {
                    get: () -> return liveAnnouncementService.desc
                }
            })
        link: link,
        templateUrl: "components/live-announcement/live-announcement.html"
    }

LiveAnnouncementDirective.$inject = [
    "tgLiveAnnouncementService"
]

angular.module("taigaComponents")
    .directive("tgLiveAnnouncement", LiveAnnouncementDirective)
