module = angular.module("taigaProject")

createProjectRestrictionDirective = () ->
    return {
        templateUrl: "project/wizard-restrictions.html"
    }

module.directive('tgCreateProjectRestriction', [createProjectRestrictionDirective])
