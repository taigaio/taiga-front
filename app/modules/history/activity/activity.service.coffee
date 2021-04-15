###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

class ActivityService
    @.$inject = [
        'tgResources',
        'tgXhrErrorService'
    ]

    constructor: (@rs, @xhrError) ->
        @._contentType = null
        @._objectId = null
        @.clear()

    clear: () ->
        @.page = 1
        @.loadingEntries = false
        @.disablePagination = false
        @.entries = Immutable.List()
        @.count = null

    fetchEntries: (reset = false) ->
        if reset
            @.page = 1
        @.loadingEntries = true
        @.disablePagination = true

        return if !@._contentType || !@._objectId

        return @rs.history.getHistory('activity', @._contentType, @._objectId, @.page)
            .then (result) =>
                if reset
                    @.clear()
                    @.entries = result.list
                else
                    @.entries = @.entries.concat(result.list)

                @.loadingEntries = false
                @.disablePagination = !result.headers('x-pagination-next')
                @.count = result.headers('x-pagination-count')
                
                return @.entries
            .catch (xhr) =>
                @xhrError.response(@.entries)

    nextPage: (historyType = 'comment') ->
        @.page++
        @.fetchEntries()

    init: (contentType, objectId) ->
        @._contentType = contentType
        @._objectId = objectId
        @.clear()


angular.module('taigaHistory').service('tgActivityService', ActivityService)
