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
