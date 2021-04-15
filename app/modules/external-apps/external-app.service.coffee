###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ExternalAppsService extends taiga.Service
    @.$inject = [
        "tgResources"
    ]

    constructor: (@rs) ->

    getApplicationToken: (applicationId, state) ->
        return @rs.externalapps.getApplicationToken(applicationId, state)

    authorizeApplicationToken: (applicationId, state) ->
        return @rs.externalapps.authorizeApplicationToken(applicationId, state)

angular.module("taigaExternalApps").service("tgExternalAppsService", ExternalAppsService)
