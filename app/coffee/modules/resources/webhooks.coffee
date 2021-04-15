###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
