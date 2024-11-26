###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
