###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
