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
