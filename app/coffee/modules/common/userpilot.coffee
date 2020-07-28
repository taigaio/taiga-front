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
# File: modules/common/analytics.coffee
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

    identify: ->
        userdata = @win.localStorage.getItem("userInfo")
        if (userdata && not @.identified)
            @.identified = true
            data = JSON.parse(userdata)
            timestamp = Date.now()
            @win.userpilot.identify(
                data["username"], # Used to identify users
                {
                    name: data["full_name_display"], # Full name
                    email: data["email"], # Email address
                    created_at: timestamp # Signup date as a Unix timestamp
                    # Additional user properties
                    # projectId: "1"
                    # trialEnds: '2019-10-31T09:29:33.401Z'
                }
            )




module.service("$tgUserPilot", UserPilotService)