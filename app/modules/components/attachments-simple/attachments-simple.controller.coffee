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
# File: components/attachments-simple/attachments-simple.controller.coffee
###

class AttachmentsSimpleController
    @.$inject = [
        "tgAttachmentsService"
    ]

    constructor: (@attachmentsService) ->

    addAttachment: (file) ->
        attachment = Immutable.fromJS({
            file: file,
            name: file.name,
            size: file.size
        })

        if @attachmentsService.validate(file)
            @.attachments = @.attachments.push(attachment)

            @.onAdd({attachment: attachment}) if @.onAdd

    addAttachments: (files) ->
        _.forEach files, @.addAttachment.bind(this)

    deleteAttachment: (toDeleteAttachment) ->
        @.attachments = @.attachments.filter (attachment) -> attachment != toDeleteAttachment

        @.onDelete({attachment: toDeleteAttachment}) if @.onDelete

angular.module("taigaComponents").controller("AttachmentsSimple", AttachmentsSimpleController)
