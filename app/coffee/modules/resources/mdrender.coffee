###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
