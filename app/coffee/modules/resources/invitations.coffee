###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

resourceProvider = ($repo) ->
    service = {}

    service.get = (token) ->
        return $repo.queryOne("invitations", token)

    return (instance) ->
        instance.invitations = service


module = angular.module("taigaResources")
module.factory("$tgInvitationsResourcesProvider", ["$tgRepo", resourceProvider])
