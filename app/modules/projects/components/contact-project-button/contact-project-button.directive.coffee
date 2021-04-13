ContactProjectButtonDirective = ->
    return {
        scope: {}
        controller: "ContactProjectButtonCtrl",
        bindToController: {
            project: '='
            layout: '@'
        }
        controllerAs: "vm",
        templateUrl: "projects/components/contact-project-button/contact-project-button.html",
    }

angular.module("taigaProjects").directive("tgContactProjectButton", ContactProjectButtonDirective)
