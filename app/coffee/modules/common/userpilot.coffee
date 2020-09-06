###
# Copyright (C) 2014-2020 Taiga Agile LLC
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
# File: modules/common/userpilot.coffee
###

taiga = @.taiga
module = angular.module("taigaCommon")

class UserPilotService extends taiga.Service
    @.$inject = ["$rootScope", "$window"]

    constructor: (@rootScope, @win) ->
        @.initialized = false
        @.identified = false

    initialize: ->
        @rootScope.$on '$locationChangeSuccess', =>
            if (@win.userpilot)
                @win.userpilot.reload()

        @.initialize = true

    identify: (force = false) ->
        userdata = @win.localStorage.getItem("userInfo")
        if (@win.userpilot and ((userdata and not @.identified) or force))
            data = JSON.parse(userdata)
            if (data["id"])
                @.identified = true
                id = @.getUserPilotId(data)
                timestamp = Date.now()
                @win.userpilot.identify(
                    id, # Used to identify users
                    {
                        name: data["full_name_display"], # Full name
                        email: data["email"], # Email address
                        created_at: timestamp, # Signup date as a Unix timestamp
                        # Additional user properties
                        taiga_id: id,
                        taiga_username: data["username"],
                        taiga_date_joined: data["date_joined"],
                        taiga_lang: data["lang"],
                        taiga_max_private_projects: parseInt(data["max_private_projects"], 10),
                        taiga_max_memberships_private_projects: parseInt(data["max_memberships_private_projects"], 10),
                        taiga_verified_email: data["verified_email"],
                        taiga_total_private_projects: parseInt(data["total_private_projects"], 10),
                        taiga_total_public_projects: parseInt(data["total_public_projects"], 10),
                        taiga_roles: data["roles"].toString()
                    }
                )

    getUserPilotId: (data) ->
        maxPrivateProjects = parseInt(data["max_private_projects"], 10)
        if (maxPrivateProjects && maxPrivateProjects > 1) then return parseInt(data["id"], 10) else 1

module.service("$tgUserPilot", UserPilotService)
