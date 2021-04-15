###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProfileContactsController
    @.$inject = [
        "tgUserService",
        "tgCurrentUserService"
    ]

    constructor: (@userService, @currentUserService) ->
        @.currentUser = @currentUserService.getUser()

        @.isCurrentUser = false

        if @.currentUser && @.currentUser.get("id") == @.user.get("id")
            @.isCurrentUser = true

    loadContacts: () ->
        @userService.getContacts(@.user.get("id"))
            .then (contacts) =>
                @.contacts = contacts

angular.module("taigaProfile")
    .controller("ProfileContacts", ProfileContactsController)
