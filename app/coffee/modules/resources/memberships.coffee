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
# File: modules/resources/memberships.coffee
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
