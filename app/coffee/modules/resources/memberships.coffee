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

    service.get = (id) ->
        return $repo.queryOne("memberships", id)

    service.list = (projectId, filters, enablePagination=true) ->
        params = {project: projectId}
        params = _.extend({}, params, filters or {})
        if enablePagination
            return $repo.queryPaginated("memberships", params)

        return $repo.queryMany("memberships", params, options={enablePagination:enablePagination})

    service.listByUser = (userId, filters) ->
        params = {user: userId}
        params = _.extend({}, params, filters or {})
        return $repo.queryPaginated("memberships", params)

    service.resendInvitation = (id) ->
        url = $urls.resolve("memberships")
        return $http.post("#{url}/#{id}/resend_invitation", {})

    service.bulkCreateMemberships = (projectId, data, invitation_extra_text) ->
        url = $urls.resolve("bulk-create-memberships")
        params = {project_id: projectId, bulk_memberships: data, invitation_extra_text: invitation_extra_text}
        return $http.post(url, params)

    return (instance) ->
        instance.memberships = service


module = angular.module("taigaResources")
module.factory("$tgMembershipsResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
