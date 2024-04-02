###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

ImportProjectDirective = () ->

    link = (scope, el, attr, ctrl) ->
        ctrl.start()

    return {
        link: link,
        templateUrl:"projects/create/import/import-project.html",
        controller: "ImportProjectCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            onCancelImport: '&'
        }
    }

ImportProjectDirective.$inject = []

angular.module("taigaProjects").directive("tgImportProject", ImportProjectDirective)
