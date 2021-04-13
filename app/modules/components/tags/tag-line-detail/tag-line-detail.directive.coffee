module = angular.module('taigaCommon')

TagLineDirective = () ->
    return {
        scope: {
            item: "=",
            permissions: "@",
            project: "="
        },
        templateUrl:"components/tags/tag-line-detail/tag-line-detail.html",
        controller: "TagLineCtrl",
        controllerAs: "vm",
        bindToController: true
    }

module.directive("tgTagLine", TagLineDirective)
