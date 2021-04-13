module = angular.module("taigaProject")

createProjectMembersRestrictionsDirective = () ->
    return {
        scope: {
            isPrivate: '=',
            limitMembersPrivateProject: '=',
            limitMembersPublicProject: '='
        },
        templateUrl: "projects/create/create-project-members-restrictions/create-project-members-restrictions.html"
    }

module.directive('tgCreateProjectMembersRestrictions', [createProjectMembersRestrictionsDirective])
