###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

resourceProvider = ($repo, $urls, $http) ->
    service = {}

    service.list = (webhookId) ->
        params = {webhook: webhookId}
        return $repo.queryMany("webhooklogs", params)

    service.resend = (webhooklogId) ->
        url = $urls.resolve("webhooklogs-resend", webhooklogId)
        return $http.post(url)

    return (instance) ->
        instance.webhooklogs = service


module = angular.module("taigaResources")
module.factory("$tgWebhookLogsResourcesProvider", ["$tgRepo", "$tgUrls", "$tgHttp", resourceProvider])
