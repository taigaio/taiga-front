###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

CommentWysiwyg = ($modelTransform, $rootscope, attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
        $scope.editableDescription = false

        $scope.saveComment = (description, cb) ->
            $scope.content = ''
            $scope.vm.type.comment = description

            transform = $modelTransform.save (item) -> return
            transform.then ->
                if $scope.vm.onAddComment
                    $scope.vm.onAddComment()
                $rootscope.$broadcast("object:updated")
            transform.finally(cb)

        types = {
            epics: "epic",
            userstories: "us",
            userstory: "us",
            issues: "issue",
            tasks: "task",
            epic: "epic",
            us: "us"
            issue: "issue",
            task: "task",
        }

        $scope.onChange = (markdown) ->
            $scope.vm.type.comment = markdown

        $scope.uploadFiles = (file, cb) ->
            return attachmentsFullService.addAttachment($scope.vm.project.id, $scope.vm.type.id, types[$scope.vm.type._name], file, true, true).then (result) ->
                cb({
                    default: result.getIn(['file', 'url'])
                })

        $scope.content = ''

        $scope.$watch "vm.type", (value) ->
            return if not value

            $scope.storageKey = "comment-" + value.project + "-" + value.id + "-" + value._name

    return {
        scope: true,
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    required
                    not-persist
                    project="vm.project"
                    placeholder="'COMMENTS.TYPE_NEW_COMMENT '| translate"
                    storage-key='storageKey'
                    content='content'
                    on-save='saveComment(text, cb)'
                    on-upload-file='uploadFiles'>
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
