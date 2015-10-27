class WatchButtonController
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

    toggleWatch: ->
        @.loading = true

        if not @.item.is_watcher
            promise = @._watch()
        else
            promise = @._unwatch()

        promise.finally () => @.loading = false

        return promise

    _watch: ->
        @.onWatch().then =>
            @.showTextWhenMouseIsLeave()

    _unwatch: ->
        @.onUnwatch()

angular.module("taigaComponents").controller("WatchButton", WatchButtonController)
