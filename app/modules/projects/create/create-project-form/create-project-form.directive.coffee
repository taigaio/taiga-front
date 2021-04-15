###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
