###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

ProfileTabsDirective = () ->
    return {
        scope: {}
        controller: "ProfileTabs"
        controllerAs: "vm"
        templateUrl: "profile/profile-tabs/profile-tabs.html"
        transclude: true
    }

angular.module("taigaProfile")
    .directive("tgProfileTabs", ProfileTabsDirective)
