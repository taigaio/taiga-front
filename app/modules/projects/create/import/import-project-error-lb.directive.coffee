###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
