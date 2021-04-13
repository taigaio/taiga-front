module = angular.module('taigaHistory')

CommentDirective = () ->

    return {
        scope: {
            name: "@",
            projectId: "@",
            object: "@",
            comment: "<",
            type: "<",
            loading: "<",
            editing: "<",
            deleting: "<",
            objectId: "<",
            editMode: "<",
            project: "<",
            onEditMode: "&",
            onDeleteComment: "&",
            onRestoreDeletedComment: "&",
            onEditComment: "&"
        },
        templateUrl:"history/comments/comment.html",
        bindToController: true,
        controller: 'CommentCtrl',
        controllerAs: "vm",
    }

module.directive("tgComment", CommentDirective)
