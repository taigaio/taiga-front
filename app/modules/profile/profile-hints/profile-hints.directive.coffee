###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ProfileHints = ($translate) ->
    return {
        scope: {},
        controller: "ProfileHints",
        controllerAs: "vm",
        templateUrl: "profile/profile-hints/profile-hints.html"
    }

ProfileHints.$inject = [
    "$translate"
]

angular.module("taigaProfile").directive("tgProfileHints", ProfileHints)
