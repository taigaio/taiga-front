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
