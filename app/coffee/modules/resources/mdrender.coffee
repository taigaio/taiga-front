###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
