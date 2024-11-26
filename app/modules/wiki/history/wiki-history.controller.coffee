###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
