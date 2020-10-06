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
    JOINED_LIMIT_DAYS = 42

    constructor: (@rootScope, @win) ->
        @.initialized = false
        @.identified = false

    initialize: ->
        @rootScope.$on '$locationChangeSuccess', =>
            if (@win.userpilot)
                @win.userpilot.reload()

        @rootScope.$on "auth:refresh", (ctx, user) =>
            @.identify(true)

        @rootScope.$on "auth:register", (ctx, user) =>
            @.identify(true)

        @rootScope.$on "auth:login", (ctx, user) =>
            @.identify(true)

        @.initialize = true

    identify: (force = false) ->
        userdata = @win.localStorage.getItem("userInfo")
        if (@win.userpilot and ((userdata and not @.identified) or force))
            data = JSON.parse(userdata)
            if (data["id"])
                userpilotData = @.prepareData(data)
                @win.userpilot.identify(
                    userpilotData["id"],
                    userpilotData["extraData"]
                )


    prepareData: (data) ->
        @.identified = true
        id = @.setUserPilotID(data)
        timestamp = Date.now()
        userpilotData = {
            name: data["full_name_display"],
            email: data["email"],
            created_at: timestamp,
            taiga_id: parseInt(data["id"], 10),
            taiga_username: data["username"],
            taiga_date_joined: data["date_joined"],
            taiga_lang: data["lang"],
            taiga_max_private_projects: parseInt(data["max_private_projects"], 10),
            taiga_max_memberships_private_projects: parseInt(data["max_memberships_private_projects"], 10),
            taiga_verified_email: data["verified_email"],
            taiga_total_private_projects: parseInt(data["total_private_projects"], 10),
            taiga_total_public_projects: parseInt(data["total_public_projects"], 10),
            taiga_roles: data["roles"] && data["roles"].toString()
        }

        return {"id": id, "extraData": userpilotData}

    setUserPilotID: (data) ->
        joined = new Date(data["date_joined"])
        maxPrivateProjects = parseInt(data["max_private_projects"], 10)

        if (joined > @.getJoinedLimit())
            return parseInt(data["id"], 10)
        else
            if (maxPrivateProjects == 1) then return 1 else parseInt(data["id"], 10)

    getJoinedLimit: ->
        limit = new Date
        limit.setDate(limit.getDate() - JOINED_LIMIT_DAYS);
        return limit


module.service("$tgUserPilot", UserPilotService)
