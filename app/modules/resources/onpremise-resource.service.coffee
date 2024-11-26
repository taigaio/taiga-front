###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

Resource = (urlsService, http, config) ->
    service = {}
    service.subscribeOnPremiseNewsletter = (requestParams) ->
        params = {
            url: config.get("newsletterSubscriberUrl") + "/subscribe/",
            method: "POST",
            cancelable: true,
            data: requestParams
        }

        return http.request(params)
            .then (result) ->
                return Immutable.fromJS(result.data)

    return () ->
        return {"onPremise": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "$tgConfig"]

module = angular.module("taigaResources2")
module.factory("tgOnPremiseResource", Resource)
