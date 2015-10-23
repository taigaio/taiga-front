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
