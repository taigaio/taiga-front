###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
