###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

VoteButtonDirective = ->
    return {
        scope: {}
        controller: "VoteButton",
        bindToController: {
            item: "=",
            onUpvote: "=",
            onDownvote: "="
        }
        controllerAs: "vm",
        templateUrl: "components/vote-button/vote-button.html",
    }

angular.module("taigaComponents").directive("tgVoteButton", VoteButtonDirective)
