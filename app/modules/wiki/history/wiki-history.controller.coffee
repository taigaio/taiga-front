###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

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
