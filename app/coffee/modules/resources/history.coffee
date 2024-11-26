###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (contentType, objectId, entryType) ->
        return $repo.queryOneRaw("history/#{contentType}", objectId, {type: entryType})

    service.editComment = (type, objectId, activityId, comment) ->
        url = $urls.resolve("history/#{type}")
        url = "#{url}/#{objectId}/edit_comment"
        params = {
            id: activityId
        }
        commentData = {
            comment: comment
        }
        return $http.post(url, commentData, params).then (data) =>
            return data.data

    service.getCommentHistory = (type, objectId, activityId) ->
        url = $urls.resolve("history/#{type}")
        url = "#{url}/#{objectId}/comment_versions"
        params = {id: activityId}
        return $http.get(url, params).then (data) =>
            return data.data

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
