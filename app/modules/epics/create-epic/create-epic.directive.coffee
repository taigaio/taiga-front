###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

CreateEpicDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        form = el.find("form").checksley()

        ctrl.validateForm = =>
            return form.validate()

        ctrl.setFormErrors = (errors) =>
            form.setErrors(errors)

    return {
        link: link,
        templateUrl:"epics/create-epic/create-epic.html",
        controller: "CreateEpicCtrl",
        controllerAs: "vm",
        bindToController: {
            onCreateEpic: '&'
        },
        scope: {}
    }

angular.module('taigaEpics').directive("tgCreateEpic", CreateEpicDirective)
