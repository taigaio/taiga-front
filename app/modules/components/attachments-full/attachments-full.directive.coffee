bindOnce = @.taiga.bindOnce

AttachmentsFullDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        scope.displayAttachmentInput = (event) ->
            angular.element('#add-attach').click();
            return false;

    return {
        scope: {},
        bindToController: {
            type: "@",
            objId: "=",
            projectId: "=",
            editPermission: "@"
        },
        controller: "AttachmentsFull",
        controllerAs: "vm",
        templateUrl: "components/attachments-full/attachments-full.html",
        link: link
    }

AttachmentsFullDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentsFull", AttachmentsFullDirective)
