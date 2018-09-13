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
# File: external-apps/external-app.controller.coffee
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
        @.loginWithAnotherUserUrl = "#{loginUrl}?next=#{nextUrl}"

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
