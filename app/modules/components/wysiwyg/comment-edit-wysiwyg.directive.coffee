###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

CommentEditWysiwyg = (attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
        $scope.uploadFiles = (file, cb) ->
            projectId = parseInt($scope.vm.projectId, 10)
            object = parseInt($scope.vm.object, 10)

            if !projectId
                projectId = parseInt($scope.vm.project.id, 10)

            return attachmentsFullService.addAttachment(
                projectId,
                object,
                attachmentsFullService.types[$scope.vm.name],
                file,
                true,
                true
            ).then (result) ->
                cb({
                    default: result.getIn(['file', 'url'])
                })

    return {
        scope: true,
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    editonly
                    required
                    project="vm.project"
                    content='vm.comment.comment'
                    on-save="vm.saveComment(text, cb)"
                    on-cancel="vm.onEditMode({commentId: vm.comment.id})"
                    on-upload-file='uploadFiles'>
                </tg-wysiwyg>
            </div>
        """
    }

angular.module("taigaComponents")
    .directive("tgCommentEditWysiwyg", ["tgAttachmentsFullService", CommentEditWysiwyg])
