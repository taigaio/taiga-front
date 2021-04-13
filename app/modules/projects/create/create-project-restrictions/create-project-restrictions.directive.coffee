module = angular.module("taigaProject")

createProjectRestrictionsDirective = () ->
    return {
        scope: {
            isPrivate: '=',
            canCreatePrivateProjects: '=',
            canCreatePublicProjects: '='
        },
        templateUrl: "projects/create/create-project-restrictions/create-project-restrictions.html"
    }

module.directive('tgCreateProjectRestrictions', [createProjectRestrictionsDirective])
