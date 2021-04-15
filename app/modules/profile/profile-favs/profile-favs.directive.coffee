###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

base = {
    scope: {},
    bindToController: {
        user: "="
        type: "@"
        q: "@"
        scrollDisabled: "@"
        isLoading: "@"
        hasNoResults: "@"
    }
    controller: null, # Define in directives
    controllerAs: "vm",
    templateUrl: "profile/profile-favs/profile-favs.html",
}


####################################################
## Liked
####################################################

ProfileLikedDirective = () ->
    return _.extend({}, base, {
        controller: "ProfileLiked"
    })

angular.module("taigaProfile").directive("tgProfileLiked", ProfileLikedDirective)


####################################################
## Voted
####################################################

ProfileVotedDirective = () ->
    return _.extend({}, base, {
        controller: "ProfileVoted"
    })

angular.module("taigaProfile").directive("tgProfileVoted", ProfileVotedDirective)


####################################################
## Watched
####################################################

ProfileWatchedDirective = () ->
    return _.extend({}, base, {
        controller: "ProfileWatched"
    })

angular.module("taigaProfile").directive("tgProfileWatched", ProfileWatchedDirective)
