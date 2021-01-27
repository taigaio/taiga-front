###
# Copyright (C) 2014-present Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: components/wysiwyg/comment-edit-wysiwyg.directive.coffee
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
