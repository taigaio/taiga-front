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
