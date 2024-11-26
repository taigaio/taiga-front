###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
