###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ContactProjectLbController
    @.$inject = [
        "lightboxService",
        "tgResources",
        "$tgConfirm",
    ]

    constructor: (@lightboxService, @rs, @confirm) ->
        @.contact = {}

    contactProject: () ->
        project = @.project.get('id')
        message = @.contact.message

        promise = @rs.projects.contactProject(project, message)
        @.sendingFeedback = true
        promise.then  =>
            @lightboxService.closeAll()
            @.sendingFeedback = false
            @confirm.notify("success")

angular.module("taigaProjects").controller("ContactProjectLbCtrl", ContactProjectLbController)
