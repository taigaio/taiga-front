###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

CustomFieldEditWysiwyg = (attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
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
            return attachmentsFullService.addAttachment($scope.project.id, $scope.ctrl.objectId.toString(), types[$scope.ctrl.type], file).then (result) ->
                cb({
                    default: result.getIn(['file', 'url'])
                })

    return {
        scope: true,
        link: link,
        template: """
            <tg-wysiwyg
                class="custom-field"
                editonly="!!customAttributeValue.value.length"
                project="project"
                content='customAttributeValue.value'
                on-save="saveCustomRichText(text, cb)"
                on-cancel="cancelCustomRichText()"
                on-upload-file='uploadFiles'>
            </tg-wysiwyg>
        """
    }

angular.module("taigaComponents")
    .directive("tgCustomFieldEditWysiwyg", ["tgAttachmentsFullService", CustomFieldEditWysiwyg])
