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
# File: components/wysiwyg/item-wysiwyg.directive.coffee
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

        uploadFile = (file, cb) ->
            return attachmentsFullService.addAttachment($scope.project.id, $scope.item.id, $attrs.type, file).then (result) ->
                cb(result.getIn(['file', 'name']), result.getIn(['file', 'url']))

        $scope.uploadFiles = (files, cb) ->
            for file in files
                uploadFile(file, cb)

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
                    ng-if="editableDescription"
                    placeholder='{{"COMMON.DESCRIPTION.EMPTY" | translate}}'
                    version='version'
                    storage-key='storageKey'
                    content='item.description'
                    on-save='saveDescription(text, cb)'
                    on-upload-file='uploadFiles(files, cb)'>
                </tg-wysiwyg>

                <div
                    class="wysiwyg"
                    ng-if="!editableDescription && item.description.length"
                    ng-bind-html="item.description | markdownToHTML"></div>

                <div
                    class="wysiwyg"
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
