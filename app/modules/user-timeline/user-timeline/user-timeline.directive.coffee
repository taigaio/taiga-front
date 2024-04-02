###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

UserTimelineDirective = ->
    return {
        templateUrl: "user-timeline/user-timeline/user-timeline.html",
        controller: "UserTimeline",
        controllerAs: "vm",
        scope: {
            projectId: "=projectid",
            user: "=",
            currentUser: "="
        },
        bindToController: true
    }

angular.module("taigaProfile").directive("tgUserTimeline", UserTimelineDirective)
