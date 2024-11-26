###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
