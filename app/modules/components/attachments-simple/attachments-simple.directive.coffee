###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

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
