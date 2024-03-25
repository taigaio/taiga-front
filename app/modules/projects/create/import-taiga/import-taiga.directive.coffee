###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

ImportTaigaDirective = () ->
    return {
        templateUrl:"projects/create/import-taiga/import-taiga.html",
        controller: "ImportTaigaCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {}
    }

angular.module("taigaProjects").directive("tgImportTaiga", ImportTaigaDirective)
