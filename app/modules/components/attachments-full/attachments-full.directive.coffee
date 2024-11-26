###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
