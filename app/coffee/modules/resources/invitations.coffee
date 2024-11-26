###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
