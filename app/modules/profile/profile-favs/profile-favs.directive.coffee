###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: profile/profile-favs/profile-favs.directive.coffee
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
