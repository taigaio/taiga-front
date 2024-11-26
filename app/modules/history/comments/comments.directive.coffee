###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
