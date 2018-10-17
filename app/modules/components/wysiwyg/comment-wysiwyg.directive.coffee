###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/wysiwyg/comment-wysiwyg.directive.coffee
###

CommentWysiwyg = ($modelTransform, $rootscope, $confirm, attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
        $scope.editableDescription = false

        $scope.saveComment = (description, cb) ->
            $scope.content = ''
            $scope.type.comment = description

            transform = $modelTransform.save (item) -> return
            transform.then ->
                if $scope.onAddComment
                    $scope.onAddComment()
            transform.finally(cb)

        types = {
            epics: "epic",
            userstories: "us",
            issues: "issue",
            tasks: "task"
        }

        uploadFile = (file, cb) ->
            return attachmentsFullService.addAttachment($scope.vm.projectId, $scope.type.id, types[$scope.type._name], file, true, true).then (result) ->
                cb(result.getIn(['file', 'name']), result.getIn(['file', 'url']))

        $scope.onChange = (markdown) ->
            $scope.type.comment = markdown

        $scope.uploadFiles = (files, cb) ->
            for file in files
                uploadFile(file, cb)

        $scope.content = ''

        $scope.$watch "type", (value) ->
            return if not value

            $scope.storageKey = "comment-" + value.project + "-" + value.id + "-" + value._name

    return {
        scope: {
            type: '=',
            onAddComment: '&'
        },
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    required
                    not-persist
                    placeholder='{{"COMMENTS.TYPE_NEW_COMMENT" | translate}}'
                    storage-key='storageKey'
                    content='content'
                    on-save='saveComment(text, cb)'
                    on-upload-file='uploadFiles(files, cb)'>
                </tg-wysiwyg>
            </div>
        """
    }

angular.module("taigaComponents")
    .directive("tgCommentWysiwyg", [
        "$tgQueueModelTransformation",
        "$rootScope",
        "tgAttachmentsFullService",
        CommentWysiwyg])
