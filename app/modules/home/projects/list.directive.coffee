HomeProjectListDirective = (projectsService) ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {}

        scope.vm.projects = projectsService.projects

        scope.vm.newProject = ->
            projectsService.newProject()

    directive = {
        templateUrl: "home/projects/list.html"
        scope: {}
        link: link
    }

    return directive

angular.module("taigaHome").directive("tgHomeProjectList", ["tgProjects", HomeProjectListDirective])
