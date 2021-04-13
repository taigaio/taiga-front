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

        fixed = false
        topBarHeight = 48

        window.addEventListener "scroll", () ->
            position = $(window).scrollTop()

            if position > topBarHeight && fixed == false
                el.find('.sticky-project-menu').addClass('unblock')
                fixed = true
            else if position == 0 && fixed == true
                el.find('.sticky-project-menu').removeClass('unblock')
                fixed = false

    return {
        scope: {},
        controller: "ProjectMenu",
        controllerAs: "vm",
        templateUrl: "components/project-menu/project-menu.html",
        link: link
    }

ProjectMenuDirective.$inject = [
    "tgProjectService",
    "tgLightboxFactory"
]

angular.module("taigaComponents").directive("tgProjectMenu", ProjectMenuDirective)
