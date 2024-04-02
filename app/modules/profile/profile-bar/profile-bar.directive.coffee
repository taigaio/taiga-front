###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

ProfileBarDirective = () ->
    return {
        templateUrl: "profile/profile-bar/profile-bar.html",
        controller: "ProfileBar",
        controllerAs: "vm",
        scope: {
            user: "=user",
            isCurrentUser: "=iscurrentuser"
        },
        bindToController: true
    }


angular.module("taigaProfile").directive("tgProfileBar", ProfileBarDirective)
