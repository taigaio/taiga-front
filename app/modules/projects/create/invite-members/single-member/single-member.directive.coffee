###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

SingleMemberDirective = () ->
    return {
        templateUrl:"projects/create/invite-members/single-member/single-member.html",
        scope: {
            disabled: "<",
            avatar: "="
        }
    }

SingleMemberDirective.$inject = []

angular.module("taigaProjects").directive("tgSingleMember", SingleMemberDirective)
