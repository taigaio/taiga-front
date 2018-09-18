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
# File: components/wysiwyg/custom-field-edit-wysiwyg.directive.coffee
###

CustomFieldEditWysiwyg = (attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
        types = {
            userstories: "us",
            issues: "issue",
            tasks: "task"
        }

        uploadFile = (file, cb) ->
            return attachmentsFullService.addAttachment($scope.vm.projectId, $scope.vm.comment.comment.id, types[$scope.vm.comment.comment._name], file).then (result) ->
                cb(result.getIn(['file', 'name']), result.getIn(['file', 'url']))

        $scope.uploadFiles = (files, cb) ->
            for file in files
                uploadFile(file, cb)

    return {
        scope: true,
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    editonly
                    content='customAttributeValue.value'
                    on-save="saveCustomRichText(text, cb)"
                    on-cancel="cancelCustomRichText()"
                    on-upload-file='uploadFiles(files, cb)'>
                </tg-wysiwyg>
            </div>
        """
    }

angular.module("taigaComponents")
    .directive("tgCustomFieldEditWysiwyg", ["tgAttachmentsFullService", CustomFieldEditWysiwyg])
