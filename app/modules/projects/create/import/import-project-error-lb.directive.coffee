###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

LbImportErrorDirective = (lightboxService) ->
    link = (scope, el, attrs) ->
        lightboxService.open(el)

        scope.close = () ->
            lightboxService.close(el)
            return

    return {
        templateUrl: "projects/create/import/import-project-error-lb.html",
        link: link
    }

LbImportErrorDirective.$inject = ["lightboxService"]

angular.module("taigaProjects").directive("tgLbImportError", LbImportErrorDirective)
