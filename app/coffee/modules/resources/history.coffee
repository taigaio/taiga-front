###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/resources/history.coffee
###


taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (type, objectId) ->
        return $repo.queryOneRaw("history/#{type}", objectId)

    service.deleteComment = (type, objectId, activityId) ->
        url = $urls.resolve("history/#{type}")
        url = "#{url}/#{objectId}/delete_comment"
        params = {id: activityId}
        return $http.post(url, null, params).then (data) =>
            return data.data

    service.undeleteComment = (type, objectId, activityId) ->
        url = $urls.resolve("history/#{type}")
        url = "#{url}/#{objectId}/undelete_comment"
        params = {id: activityId}
        return $http.post(url, null, params).then (data) =>
            return data.data

    return (instance) ->
        instance.history = service


module = angular.module("taigaResources")
module.factory("$tgHistoryResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
