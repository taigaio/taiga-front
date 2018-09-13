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
# File: components/vote-button/vote-button.controller.coffee
###

class VoteButtonController
    @.$inject = [
        "tgCurrentUserService",
    ]

    constructor: (@currentUserService) ->
        @.user = @currentUserService.getUser()
        @.isMouseOver = false
        @.loading = false

    showTextWhenMouseIsOver: ->
        @.isMouseOver = true

    showTextWhenMouseIsLeave: ->
        @.isMouseOver = false

    toggleVote: ->
        @.loading = true

        if not @.item.is_voter
            promise = @._upvote()
        else
            promise = @._downvote()

        promise.finally () => @.loading = false

        return promise

    _upvote: ->
        @.onUpvote().then =>
            @.showTextWhenMouseIsLeave()

    _downvote: ->
        @.onDownvote()

angular.module("taigaComponents").controller("VoteButton", VoteButtonController)
