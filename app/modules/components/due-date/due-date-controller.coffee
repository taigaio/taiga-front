###
# Copyright (C) 2014-2018 Taiga Agile LLC <taiga@taiga.io>
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
# File: due-date-controller.coffee
###

class DueDateController
    @.$inject = [
        "$translate"
        "tgLightboxFactory"
    ]

    constructor: (@translate, @tgLightboxFactory) ->

    visible: () ->
        return @.format == 'button' or @.dueDate?

    disabled: () ->
        return @.isClosed

    color: () ->
        colors = {
            'no_longer_applicable': 'closed',
            'due_soon': 'due-soon',
            'past_due': 'past-due',
            'set': 'due-set',
        }
        return colors[@.dueDateStatus] or ''

    title: () ->
        if @.format == 'button'
            return if @.dueDate then @._formatTitle() else 'EDIT DUE DATE'

        return @._formatTitle()

    _formatTitle: () ->
        dueDateStatus = 'closed'
        titles = {
            'no_longer_applicable': 'COMMON.DUE_DATE.NO_LONGER_APPLICABLE',
            'due_soon': 'COMMON.DUE_DATE.DUE_SOON',
            'past_due': 'COMMON.DUE_DATE.PAST_DUE',
        }
        prettyDate = @translate.instant("COMMON.PICKERDATE.FORMAT")
        formatedDate = moment(@.dueDate).format(prettyDate)

        if not titles[@.dueDateStatus]
            return formatedDate
        return "#{formatedDate} (#{@translate.instant(titles[@.dueDateStatus])})"

    setDueDate: () ->
        event.preventDefault()
        return if @.disabled()
        @tgLightboxFactory.create(
            "tg-lb-set-due-date",
            {"class": "lightbox lightbox-set-due-date"},
            {"object": @.item}
        )

angular.module('taigaComponents').controller('DueDate', DueDateController)
