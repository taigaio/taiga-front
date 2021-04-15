###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

UserTimelineItemDirective = () ->
    return {
        templateUrl: "user-timeline/user-timeline-item/user-timeline-item.html"
        scope: {
            timeline: "=tgUserTimelineItem"
        }
    }

angular.module("taigaUserTimeline")
    .directive("tgUserTimelineItem", UserTimelineItemDirective)
