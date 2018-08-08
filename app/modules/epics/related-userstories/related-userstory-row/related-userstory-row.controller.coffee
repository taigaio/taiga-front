###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: reñated-userstory-row.controller.coffee
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
        title = @translate.instant('EPIC.TITLE_LIGHTBOX_UNLINK_RELATED_USERSTORY')
        message = @translate.instant('EPIC.MSG_LIGHTBOX_UNLINK_RELATED_USERSTORY', {
            subject: @.userstory.get('subject')
        })
        subtitle = @translate.instant('NOTIFICATION.ASK_REMOVE_LINK')
        return @confirm.askOnDelete(title, message, subtitle)
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
