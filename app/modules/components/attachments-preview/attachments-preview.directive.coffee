###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

AttachmentPreviewLightboxDirective = (lightboxService, attachmentsPreviewService) ->
    link = ($scope, el, attrs, ctrl) ->
        $(document.body).on "keydown.image-preview", (e) ->
            if attachmentsPreviewService.fileId
                if e.keyCode == 39
                    ctrl.next()
                else if e.keyCode == 37
                    ctrl.previous()

            $scope.$digest()

        $scope.$on '$destroy', () ->
            $(document.body).off('.image-preview')

    return {
        scope: {},
        controller: 'AttachmentsPreview',
        templateUrl: 'components/attachments-preview/attachments-preview.html',
        link: link,
        controllerAs: "vm",
        bindToController: {
            attachments: "="
        }
    }

angular.module('taigaComponents').directive("tgAttachmentsPreview", [
    "lightboxService",
    "tgAttachmentsPreviewService",
    AttachmentPreviewLightboxDirective])
