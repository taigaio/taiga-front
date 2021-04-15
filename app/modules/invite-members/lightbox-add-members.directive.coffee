###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

LightboxAddMembersDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        lightboxService.open(el)
        ctrl._getContacts()

    return {
        scope: {},
        templateUrl:"invite-members/lightbox-add-members.html",
        controller: "AddMembersCtrl",
        controllerAs: "vm",
        link: link
    }

angular.module("taigaAdmin").directive("tgLbAddMembers", ["lightboxService", LightboxAddMembersDirective])
