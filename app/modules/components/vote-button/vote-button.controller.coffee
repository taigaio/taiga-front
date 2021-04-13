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
