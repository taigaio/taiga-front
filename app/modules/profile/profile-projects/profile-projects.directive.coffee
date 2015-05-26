ProfileProjectsDirective = () ->
    link = (scope, elm, attr, ctrl) ->
        ctrl.loadProjects()

    return {
        templateUrl: "profile/profile-projects/profile-projects.html",
        scope: {
            userId: "=userid"
        },
        link: link
        bindToController: true,
        controllerAs: "vm",
        controller: "ProfileProjects"
    }

angular.module("taigaProfile").directive("tgProfileProjects", ProfileProjectsDirective)
