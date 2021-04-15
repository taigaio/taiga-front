###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
