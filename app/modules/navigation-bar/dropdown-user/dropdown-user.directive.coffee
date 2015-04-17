DropdownUserDirective = () ->
    directive = {
        templateUrl: "navigation-bar/dropdown-user/dropdown-user.html"
        controller: "ProjectsController"
        scope: {}
        bindToController: true
        controllerAs: "vm"
    }

    return directive

angular.module("taigaNavigationBar").directive("tgDropdownUser",
    DropdownUserDirective)
