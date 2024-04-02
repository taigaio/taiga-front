###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
