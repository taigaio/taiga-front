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
        "tgProjectService"
    ]

    constructor: (@translate, @tgLightboxFactory, @projectService) ->

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
            'not_set': 'not-set',
        }
        return colors[@status()] or ''

    title: () ->
        if @.dueDate
            return @._formatTitle()
        else if @.format == 'button'
            return @translate.instant('COMMON.DUE_DATE.TITLE_ACTION_SET_DUE_DATE')
        return ''

    status: () ->
        if !@.dueDate
            return 'not_set'

        project = @projectService.project.toJS()
        project.due_soon_threshold = 14  # TODO get value from taiga-back
        dueDate = moment(@.dueDate)
        now = moment()

        if @.isClosed
            return 'no_longer_applicable'
        else if now > dueDate
            return 'past_due'
        else if now.add(moment.duration(project.due_soon_threshold, "days")) >= dueDate
            return 'due_soon'
        return 'set'

    _formatTitle: () ->
        titles = {
            'no_longer_applicable': 'COMMON.DUE_DATE.NO_LONGER_APPLICABLE',
            'due_soon': 'COMMON.DUE_DATE.DUE_SOON',
            'past_due': 'COMMON.DUE_DATE.PAST_DUE',
        }
        prettyDate = @translate.instant("COMMON.PICKERDATE.FORMAT")
        formatedDate = moment(@.dueDate).format(prettyDate)

        status = @status()
        if not titles[status]
            return formatedDate
        return "#{formatedDate} (#{@translate.instant(titles[status])})"

    setDueDate: () ->
        return if @.disabled()
        @tgLightboxFactory.create(
            "tg-lb-set-due-date",
            {"class": "lightbox lightbox-set-due-date"},
            {"object": @.item, "notAutoSave": @.notAutoSave}
        )

angular.module('taigaComponents').controller('DueDateCtrl', DueDateController)
