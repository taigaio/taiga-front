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
# File: profile/profile.controller.coffee
###

class ProfileController
    @.$inject = [
        "tgAppMetaService",
        "tgCurrentUserService",
        "$routeParams",
        "tgUserService",
        "tgXhrErrorService",
        "$translate"
    ]

    constructor: (@appMetaService, @currentUserService, @routeParams, @userService, @xhrError, @translate) ->
        @.isCurrentUser = false

        if @routeParams.slug
            @userService
                .getUserByUserName(@routeParams.slug)
                .then (user) =>
                    if !user.get('is_active')
                        @xhrError.notFound()
                    else
                        @.user = user
                        @.isCurrentUser = false
                        @._setMeta(@.user)

                        return user
                .catch (xhr) =>
                    return @xhrError.response(xhr)

        else
            @.user = @currentUserService.getUser()
            @.isCurrentUser = true
            @._setMeta(@.user)

    _setMeta: (user) ->
        ctx = {
            userFullName: user.get("full_name_display"),
            userUsername: user.get("username")
        }

        title = @translate.instant("USER.PROFILE.PAGE_TITLE", ctx)

        description = user.get("bio")
        @appMetaService.setAll(title, description)

angular.module("taigaProfile").controller("Profile", ProfileController)
