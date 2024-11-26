###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
