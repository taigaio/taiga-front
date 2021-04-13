module = angular.module('taigaCommon')

TagDirective = () ->
    return {
        templateUrl:"components/tags/tag/tag.html",
        scope: {
            tag: "<",
            loadingRemoveTag: "<",
            onDeleteTag: "&",
            hasPermissions: "<"
        },
    }

module.directive("tgTag", TagDirective)
