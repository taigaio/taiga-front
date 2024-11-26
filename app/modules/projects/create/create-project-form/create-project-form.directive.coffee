###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

CreateProjectFormDirective = () ->
    return {
        templateUrl:"projects/create/create-project-form/create-project-form.html",
        controller: "CreateProjectFormCtrl",
        controllerAs: "vm",
        bindToController: true,
        scope: {
            type: '@'
        }
    }

angular.module("taigaProjects").directive("tgCreateProjectForm", CreateProjectFormDirective)
