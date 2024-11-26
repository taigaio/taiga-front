###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
