###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ProfileContactsDirective = () ->
    link = (scope, elm, attrs, ctrl) ->
        ctrl.loadContacts()

    return {
        templateUrl: "profile/profile-contacts/profile-contacts.html",
        scope: {
            user: "="
        },
        controllerAs: "vm",
        controller: "ProfileContacts",
        link: link,
        bindToController: true
    }

angular.module("taigaProfile").directive("tgProfileContacts", ProfileContactsDirective)
