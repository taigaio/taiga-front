###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class LiveAnnouncementService extends taiga.Service
    constructor: () ->
        @.open = false
        @.title = ""
        @.desc = ""

    show: (title, desc) ->
        @.open = true
        @.title = title
        @.desc = desc

angular.module("taigaComponents").service("tgLiveAnnouncementService", LiveAnnouncementService)
