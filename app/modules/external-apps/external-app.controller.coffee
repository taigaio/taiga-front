###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

class ExternalAppController extends taiga.Controller
    @.$inject = [
        "$routeParams",
        "tgExternalAppsService",
        "$window",
        "tgCurrentUserService",
        "$location",
        "$tgNavUrls",
        "tgXhrErrorService",
        "tgLoader"
    ]

    constructor: (@routeParams, @externalAppsService, @window, @currentUserService, @location,
    @navUrls, @xhrError, @loader) ->
        @loader.start(false)
        @._applicationId = @routeParams.application
        @._state = @routeParams.state
        @._getApplicationToken()
        @._user = @currentUserService.getUser()
        @._application = null
        nextUrl = encodeURIComponent(@location.url())
        loginUrl = @navUrls.resolve("login")
        @.loginWithAnotherUserUrl = "#{loginUrl}?next=#{nextUrl}&force_login=1"

        taiga.defineImmutableProperty @, "user", () => @._user
        taiga.defineImmutableProperty @, "application", () => @._application

    _redirect: (applicationToken) =>
        nextUrl = applicationToken.get("next_url")
        @window.open(nextUrl, "_self")

    _getApplicationToken: =>
        return @externalAppsService.getApplicationToken(@._applicationId, @._state)
            .then (data) =>
                @._application = data.get("application")
                if data.get("auth_code")
                    @._redirect(data)
                else
                    @loader.pageLoaded()

            .catch (xhr) =>
                @loader.pageLoaded()
                return @xhrError.response(xhr)

    cancel: () ->
        @window.history.back()

    createApplicationToken:  =>
        return @externalAppsService.authorizeApplicationToken(@._applicationId, @._state)
            .then (data) =>
                @._redirect(data)
            .catch (xhr) =>
                return @xhrError.response(xhr)


angular.module("taigaExternalApps").controller("ExternalApp", ExternalAppController)
