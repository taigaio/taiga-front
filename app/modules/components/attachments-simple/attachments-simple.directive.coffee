AttachmentsSimpleDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        scope.displayAttachmentInput = (event) ->
            angular.element('#add-attach').click();
            return false;

    return {
        scope: {},
        bindToController: {
            attachments: "=",
            onAdd: "&",
            onDelete: "&"
        },
        controller: "AttachmentsSimple",
        controllerAs: "vm",
        templateUrl: "components/attachments-simple/attachments-simple.html",
        link: link
    }

AttachmentsSimpleDirective.$inject = []

angular.module("taigaComponents").directive("tgAttachmentsSimple", AttachmentsSimpleDirective)
