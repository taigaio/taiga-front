###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaEpics")

class RelatedUserstoryRowController
    @.$inject = [
        "tgAvatarService",
        "$translate",
        "$tgConfirm",
        "tgResources"
    ]

    constructor: (@avatarService, @translate, @confirm, @rs) ->

    setAvatarData: () ->
        member = @.userstory.get('assigned_to_extra_info')
        @.avatar = @avatarService.getAvatar(member)

    getAssignedToFullNameDisplay: () ->
        if @.userstory.get('assigned_to')
            return @.userstory.getIn(['assigned_to_extra_info', 'full_name_display'])

        return @translate.instant("COMMON.ASSIGNED_TO.NOT_ASSIGNED")

    onDeleteRelatedUserstory: () ->
        title = @translate.instant("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.TITLE")
        message = @translate.instant(
            "LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.MESSAGE",
            { epicSubject: @.epic.get('subject') }
        )

        return @confirm.ask(title, null, message)
            .then (askResponse) =>
                onError = () =>
                    message = @translate.instant('EPIC.ERROR_UNLINK_RELATED_USERSTORY', {errorMessage: message})
                    @confirm.notify("error", null, message)
                    askResponse.finish(false)

                onSuccess = () =>
                    @.loadRelatedUserstories()
                    askResponse.finish()

                epicId = @.epic.get('id')
                userstoryId = @.userstory.get('id')
                @rs.epics.deleteRelatedUserstory(epicId, userstoryId).then(onSuccess, onError)

module.controller("RelatedUserstoryRowCtrl", RelatedUserstoryRowController)
