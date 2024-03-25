###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
