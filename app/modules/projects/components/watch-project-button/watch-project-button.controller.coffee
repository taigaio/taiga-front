class WatchProjectButtonController
    @.$inject = [
        "$tgConfirm"
        "tgWatchProjectButtonService"
    ]

    constructor: (@confirm, @watchButtonService)->
        @.showWatchOptions = false
        @.loading = false

    toggleWatcherOptions: () ->
        @.showWatchOptions = !@.showWatchOptions

    closeWatcherOptions: () ->
        @.showWatchOptions = false

    watch: (notifyLevel) ->
        return if notifyLevel == @.project.get('notify_level')

        @.loading = true
        @.closeWatcherOptions()

        return @watchButtonService.watch(@.project.get('id'), notifyLevel)
            .catch () => @confirm.notify("error")
            .finally () => @.loading = false

    unwatch: ->
        @.loading = true
        @.closeWatcherOptions()

        return @watchButtonService.unwatch(@.project.get('id'))
            .catch () => @confirm.notify("error")
            .finally () => @.loading = false

angular.module("taigaProjects").controller("WatchProjectButton", WatchProjectButtonController)
