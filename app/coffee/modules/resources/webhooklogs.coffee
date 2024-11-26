###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
