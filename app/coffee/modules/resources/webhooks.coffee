###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

resourceProvider = ($repo, $urls, $http) ->
    service = {}

    service.list = (projectId) ->
        params = {project: projectId}
        return $repo.queryMany("webhooks", params)

    service.test = (webhookId) ->
        url = $urls.resolve("webhooks-test", webhookId)
        return $http.post(url)

    return (instance) ->
        instance.webhooks = service


module = angular.module("taigaResources")
module.factory("$tgWebhooksResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", resourceProvider])
