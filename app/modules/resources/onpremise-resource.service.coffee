###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
