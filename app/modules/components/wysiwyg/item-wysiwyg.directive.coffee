###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

# Used in details descriptions
ItemWysiwyg = ($modelTransform, $rootscope, $confirm, attachmentsFullService, $translate) ->
    link = ($scope, $el, $attrs) ->
        $scope.editableDescription = false
        $scope.saveDescription = (description, cb) ->
            transform = $modelTransform.save (item) ->
                item.description = description

                return item

            transform.then ->
                $confirm.notify("success")
                $rootscope.$broadcast("object:updated")

            transform.then null, ->
                $confirm.notify("error")

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

        $scope.uploadFiles = (file, cb) ->
            return attachmentsFullService.addAttachment($scope.project.id, $scope.item.id, types[$attrs.type], file).then (result) ->
                cb({
                    default: result.getIn(['file', 'url'])
                })

        $scope.$watch $attrs.model, (value) ->
            return if not value
            $scope.item = value
            $scope.version = value.version
            $scope.storageKey = $scope.project.id + "-" + value.id + "-" + $attrs.type

        $scope.$watch 'project', (project) ->
            return if !project

            $scope.editableDescription = project.my_permissions.indexOf($attrs.requiredPerm) != -1

    return {
        scope: true,
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    ng-if="editableDescription && project"
                    html-read-mode="true"
                    project="project"
                    placeholder="'COMMON.DESCRIPTION.EMPTY '| translate"
                    version='version'
                    storage-key='storageKey'
                    content='item.description'
                    on-save='saveDescription(text, cb)'
                    on-upload-file='uploadFiles'>
                </tg-wysiwyg>
                <div
                    class="wysiwyg"
                    ng-if="!editableDescription && item.description.length"
                    tg-bind-wysiwyg-html="item.description"></div>

                <div
                    class="wysiwyg no-description"
                    ng-if="!editableDescription && !item.description.length">
                    {{'COMMON.DESCRIPTION.NO_DESCRIPTION' | translate}}
                </div>
            </div>
        """
    }

angular.module("taigaComponents")
    .directive("tgItemWysiwyg", [
        "$tgQueueModelTransformation",
        "$rootScope",
        "$tgConfirm",
        "tgAttachmentsFullService",
        "$translate",
        ItemWysiwyg])
