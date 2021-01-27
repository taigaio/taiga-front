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
# File: components/wysiwyg/custom-field-edit-wysiwyg.directive.coffee
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
            <div>
                <tg-wysiwyg
                    editonly="!!customAttributeValue.value.length"
                    project="project"
                    content='customAttributeValue.value'
                    on-save="saveCustomRichText(text, cb)"
                    on-cancel="cancelCustomRichText()"
                    on-upload-file='uploadFiles'>
                </tg-wysiwyg>
            </div>
        """
    }

angular.module("taigaComponents")
    .directive("tgCustomFieldEditWysiwyg", ["tgAttachmentsFullService", CustomFieldEditWysiwyg])
