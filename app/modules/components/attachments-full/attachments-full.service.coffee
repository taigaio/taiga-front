###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: components/attachments-full/attachments-full.service.coffee
###

class AttachmentsFullService extends taiga.Service
    @.$inject = [
        "tgAttachmentsService",
        "$rootScope"
    ]

    constructor: (@attachmentsService, @rootScope) ->
        @._attachments = Immutable.List()
        @._deprecatedsCount = 0
        @._attachmentsVisible = Immutable.List()
        @._deprecatedsVisible = false
        @.uploadingAttachments = []

        taiga.defineImmutableProperty @, 'attachments', () => return @._attachments
        taiga.defineImmutableProperty @, 'deprecatedsCount', () => return @._deprecatedsCount
        taiga.defineImmutableProperty @, 'attachmentsVisible', () => return @._attachmentsVisible
        taiga.defineImmutableProperty @, 'deprecatedsVisible', () => return @._deprecatedsVisible

    toggleDeprecatedsVisible: () ->
        @._deprecatedsVisible = !@._deprecatedsVisible
        @.regenerate()

    regenerate: () ->
        @._deprecatedsCount = @._attachments.count (it) -> it.getIn(['file', 'is_deprecated'])

        if @._deprecatedsVisible
            @._attachmentsVisible = @._attachments
        else
            @._attachmentsVisible = @._attachments.filter (it) -> !it.getIn(['file', 'is_deprecated'])

    addAttachment: (projectId, objId, type, file, editable = true, comment = false) ->
        return new Promise (resolve, reject) =>
            if @attachmentsService.validate(file)
                @.uploadingAttachments.push(file)

                promise = @attachmentsService.upload(file, objId, projectId, type, comment)
                promise.then (file) =>
                    @.uploadingAttachments = @.uploadingAttachments.filter (uploading) ->
                        return uploading.name != file.get('name')

                    attachment = Immutable.Map()

                    attachment = attachment.merge({
                        file: file,
                        editable: editable,
                        loading: false,
                        from_comment: comment
                    })

                    @._attachments = @._attachments.push(attachment)

                    @.regenerate()

                    @rootScope.$broadcast("attachment:create")

                    resolve(attachment)
            else
                reject(new Error(file))

    loadAttachments: (type, objId, projectId)->
        @attachmentsService.list(type, objId, projectId).then (files) =>
            @._attachments = files.map (file) ->
                attachment = Immutable.Map()

                return attachment.merge({
                    loading: false,
                    editable: false,
                    file: file
                })

            @.regenerate()

    deleteAttachment: (toDeleteAttachment, type) ->
        onSuccess = () =>
            @._attachments = @._attachments.filter (attachment) -> attachment != toDeleteAttachment

            @.regenerate()

        return @attachmentsService.delete(type, toDeleteAttachment.getIn(['file', 'id'])).then(onSuccess)

    reorderAttachment: (type, attachment, newIndex) ->
        oldIndex = @.attachments.findIndex (it) -> it == attachment
        return if oldIndex == newIndex

        attachments = @.attachments.remove(oldIndex)
        attachments = attachments.splice(newIndex, 0, attachment)
        attachments = attachments.map (x, i) -> x.setIn(['file', 'order'], i + 1)

        promises = []
        attachments.forEach (attachment) =>
            patch = {order: attachment.getIn(['file', 'order'])}

            promises.push @attachmentsService.patch(attachment.getIn(['file', 'id']), type, patch)
            
        return Promise.all(promises).then () =>
            @._attachments = attachments

            @.regenerate()

    updateAttachment: (toUpdateAttachment, type) ->
        index = @._attachments.findIndex (attachment) ->
            return attachment.getIn(['file', 'id']) == toUpdateAttachment.getIn(['file', 'id'])

        oldAttachment = @._attachments.get(index)

        patch = taiga.patch(oldAttachment.get('file'), toUpdateAttachment.get('file'))

        if toUpdateAttachment.get('loading')
            @._attachments = @._attachments.set(index, toUpdateAttachment)

            @.regenerate()
        else
            return @attachmentsService.patch(toUpdateAttachment.getIn(['file', 'id']), type, patch).then () =>
                @._attachments = @._attachments.set(index, toUpdateAttachment)

                @.regenerate()

angular.module("taigaComponents").service("tgAttachmentsFullService", AttachmentsFullService)
