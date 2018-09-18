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
# File: modules/resources/mdrender.coffee
###


taiga = @.taiga

resourceProvider = ($repo, $urls, $http) ->
    service = {}

    service.render = (projectId, content) ->
        # We can't use an empty content
        content = ' ' if not content? or content == ""

        params = {
            project_id: projectId
            content: content
        }
        url = $urls.resolve("wiki")
        return $http.post("#{url}/render", params).then (data) =>
            return data.data

    return (instance) ->
        instance.mdrender = service


module = angular.module("taigaResources")
module.factory("$tgMdRenderResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", resourceProvider])
