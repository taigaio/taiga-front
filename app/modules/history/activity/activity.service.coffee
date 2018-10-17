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
# File: history/activity/activity.service.coffee
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
