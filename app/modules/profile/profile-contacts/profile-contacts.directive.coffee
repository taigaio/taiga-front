ProfileContactsDirective = () ->
    link = (scope, elm, attrs, ctrl) ->
        ctrl.loadContacts()

    return {
        templateUrl: "profile/profile-contacts/profile-contacts.html",
        scope: {},
        controllerAs: "vm",
        controller: "ProfileContacts",
        link: link
    }

angular.module("taigaProfile").directive("tgProfileContacts", ProfileContactsDirective)
