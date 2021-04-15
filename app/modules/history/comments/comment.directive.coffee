###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
