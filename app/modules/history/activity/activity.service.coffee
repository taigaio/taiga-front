###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
