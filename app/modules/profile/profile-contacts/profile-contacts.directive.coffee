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
