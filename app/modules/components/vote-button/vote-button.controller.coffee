###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class VoteButtonController
    @.$inject = [
        "tgCurrentUserService",
    ]

    constructor: (@currentUserService) ->
        @.user = @currentUserService.getUser()
        @.loading = false

    toggleVote: ->
        @.loading = true

        if not @.item.is_voter
            promise = @.onUpvote()
        else
            promise = @.onDownvote()

        promise.finally () => @.loading = false

        return promise

angular.module("taigaComponents").controller("VoteButton", VoteButtonController)
