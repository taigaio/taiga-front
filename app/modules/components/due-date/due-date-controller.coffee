###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class DueDateController
    @.$inject = [
        "tgDueDateService",
        "tgLightboxFactory"
    ]

    constructor: (@dueDateService, @tgLightboxFactory) ->

    visible: () ->
        return @dueDateService.visible(@._getScope())

    disabled: () ->
        return @dueDateService.disabled(@._getScope())

    color: () ->
        return @dueDateService.color(@._getScope())

    title: () ->
        return @dueDateService.title(@._getScope())

    setDueDate: () ->
        return if @.disabled()
        @tgLightboxFactory.create(
            "tg-lb-set-due-date",
            {"class": "lightbox lightbox-set-due-date"},
            {"object": @.item, "notAutoSave": @.notAutoSave}
        )

    _getScope: () ->
        return {
            dueDate: @.dueDate,
            isClosed: @.isClosed,
            item: @.item,
            objType: @.objType,
            format: @.format,
            notAutoSave: @.notAutoSave
        }

angular.module('taigaComponents').controller('DueDateCtrl', DueDateController)
