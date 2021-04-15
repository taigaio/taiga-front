###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
