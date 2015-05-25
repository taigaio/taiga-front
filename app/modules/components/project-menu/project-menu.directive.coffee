taiga = @.taiga

ProjectMenuDirective = (projectService, lightboxFactory) ->
    link = (scope, el, attrs, ctrl) ->
        projectChange = () ->
            if projectService.project
                ctrl.show()
            else
                ctrl.hide()

        scope.$watch ( () ->
            return projectService.project
        ), projectChange

    return {
        scope: {},
        controller: "ProjectMenu",
        templateUrl: "components/project-menu/project-menu.html",
        link: link,
        controllerAs: "vm",
        replace: true
    }

ProjectMenuDirective.$inject = [
    "tgProjectService",
    "tgLightboxFactory"
]

angular.module("taigaComponents").directive("tgProjectMenu", ProjectMenuDirective)
