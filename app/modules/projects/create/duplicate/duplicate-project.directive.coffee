DuplicateProjectDirective = () ->

    link = (scope, el, attr, ctrl) ->

    return {
        link: link,
        templateUrl:"projects/create/duplicate/duplicate-project.html",
        controller: "DuplicateProjectCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {}
    }

DuplicateProjectDirective.$inject = []

angular.module("taigaProjects").directive("tgDuplicateProject", DuplicateProjectDirective)
