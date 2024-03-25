###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
