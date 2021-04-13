module = angular.module('taigaHistory')

CommentsDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        ctrl.initializePermissions()

    return {
        scope: {
            type: "<",
            name: "@",
            object: "@",
            comments: "<",
            onEditMode: "&",
            onDeleteComment: "&",
            onRestoreDeletedComment: "&",
            onAddComment: "&",
            onEditComment: "&",
            editMode: "<",
            loading: "<",
            deleting: "<",
            editing: "<",
            project: "=",
            reverse: "="
        },
        templateUrl:"history/comments/comments.html",
        bindToController: true,
        controller: 'CommentsCtrl',
        controllerAs: "vm"
        link: link
    }

module.directive("tgComments", CommentsDirective)
