SuggestAddMembersDirective = (lightboxService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.$watch "vm.contacts", (contacts) =>
            if contacts
                ctrl.filterContacts()

    return {
        scope: {},
        templateUrl:"invite-members/suggest-add-members/suggest-add-members.html",
        controller: "SuggestAddMembersCtrl",
        controllerAs: "vm",
        bindToController: {
            contacts: '=',
            onInviteSuggested: '&',
            onInviteEmail: '&'
        },
        link: link
    }

angular.module("taigaAdmin").directive("tgSuggestAddMembers", ["lightboxService", SuggestAddMembersDirective])
