###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/resources/invitations.coffee
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
