###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
