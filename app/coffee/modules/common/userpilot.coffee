###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
module = angular.module("taigaCommon")

class UserPilotService extends taiga.Service
    @.$inject = ["$rootScope", "$window"]
    JOINED_LIMIT_DAYS = 42

    constructor: (@rootScope, @win) ->
        @.initialized = false

    initialize: ->
        if @.initialized
            return

        @rootScope.$on '$locationChangeSuccess', =>
            if (@win.userpilot)
                @win.userpilot.reload()

        @rootScope.$on "auth:refresh", (ctx, user) =>
            @.identify()

        @rootScope.$on "auth:register", (ctx, user) =>
            @.identify()

        @rootScope.$on "auth:login", (ctx, user) =>
            @.identify()

        @rootScope.$on "auth:logout", (ctx, user) =>
            @.identify()

        @.initialized = true

    checkZendeskConditions: (userData) ->
        hasPaidPlan = @.hasPaidPlan(userData)
        joined = new Date(userData["date_joined"])
        is_new_user = joined > @.getJoinedLimit()
        return hasPaidPlan and is_new_user

    identify: () ->
        userInfo = @win.localStorage.getItem("userInfo") or "{}"
        userData = JSON.parse(userInfo)

        if @win.userpilot
            userPilotId = @.calculateUserPilotId(userData)
            userPilotCustomer = @.prepareUserPilotCustomer(userData)
            @win.userpilot.identify(
                userPilotId,
                userPilotCustomer
            )

        if @win.zE
            if @.checkZendeskConditions(userData)
                @.setZendeskWidgetStatus({enabled: true})
            else
                @.setZendeskWidgetStatus({enabled: false})

    prepareUserPilotCustomer: (data) ->
        if not data["id"]
            return {
                created_at: Date.now(),
            }

        return {
            name: data["full_name_display"],
            email: data["email"],
            created_at: Date.now(),
            taiga_id: data["id"],
            taiga_username: data["username"],
            taiga_date_joined: data["date_joined"],
            taiga_lang: data["lang"],
            taiga_max_private_projects: data["max_private_projects"],
            taiga_max_memberships_private_projects: data["max_memberships_private_projects"],
            taiga_verified_email: data["verified_email"],
            taiga_total_private_projects: data["total_private_projects"],
            taiga_total_public_projects: data["total_public_projects"],
            taiga_roles: data["roles"] && data["roles"].toString()
        }

    hasPaidPlan: (data) ->
        maxPrivateProjects = data["max_private_projects"]
        return maxPrivateProjects != undefined and maxPrivateProjects != 1

    calculateUserPilotId: (data) ->
        if not data["id"]
            return 2

        joined = new Date(data["date_joined"])

        if (joined > @.getJoinedLimit()) or @.hasPaidPlan(data)
            return data["id"]

        return 1

    getJoinedLimit: ->
        limit = new Date
        limit.setDate(limit.getDate() - JOINED_LIMIT_DAYS)
        return limit

    setZendeskWidgetStatus: (config={enabled: false}) ->
        supress = !config.enabled

        @win.zE('webWidget', 'updateSettings', {
            webWidget: {
                chat: {
                    suppress: supress
                },
                contactForm: {
                    suppress: supress
                },
                helpCenter: {
                    suppress: supress
                },
                talk: {
                    suppress: supress
                },
                answerBot: {
                    suppress: supress
                }
            }
        })


module.service("$tgUserPilot", UserPilotService)
