taiga = @.taiga

module = angular.module("taigaWikiHistory")

class WikiHistoryController
    @.$inject = [
        "tgActivityService"
    ]

    constructor: (@activityService) ->
        taiga.defineImmutableProperty @, 'historyEntries', () =>
            return @activityService.entries
        taiga.defineImmutableProperty @, 'disablePagination', () =>
            return @activityService.disablePagination
        @.toggle = false

    initializeHistory: (wikiId) ->
        if wikiId
            @activityService.init('wiki', wikiId)
        @.loadHistory()

    loadHistory: ()->
        @activityService.fetchEntries()

    nextPage: () ->
        @activityService.nextPage()

module.controller("WikiHistoryCtrl", WikiHistoryController)
