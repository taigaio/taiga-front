###
# Copyright (C) 2014-present Taiga Agile LLC
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
# File: components/due-date/due-date-controller.coffee
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
