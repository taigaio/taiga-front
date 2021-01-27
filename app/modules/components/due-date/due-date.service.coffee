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
# File: components/due-date/due-date.service.coffee
###

taiga = @.taiga

class DueDateService
    @.$inject = [
        "$translate"
        "tgProjectService"
    ]

    constructor: (@translate, @projectService) ->
        @.defaultConfig = [
            {"color": "#93C45D", "name": "normal due", "days_to_due": null, "by_default": true},
            {"color": "#EA7B4B", "name": "due soon", "days_to_due": 14, "by_default": false},
            {"color": "#E44057", "name": "past due", "days_to_due": 0, "by_default": false}
        ]

    visible: (options) ->
        return options.format == 'button' or options.dueDate?

    disabled: (options) ->
        return options.isClosed

    color: (options) ->
        return @.getStatus(options)?.color || null

    title: (options) ->
        if options.dueDate
            return @._formatTitle(options)
        else if options.format == 'button'
            return @translate.instant('COMMON.DUE_DATE.TITLE_ACTION_SET_DUE_DATE')
        return ''

    getStatus: (options) ->
        if !options.dueDate
            return null

        project = @projectService.project.toJS()
        config = project["#{options.objType}_duedates"]

        if !config
            config = @.defaultConfig

        return @._getAppearance(options, config)

    _getDefaultAppearance: (config) ->
        defaultAppearance = null
        _.map config, (it) ->
            if it.by_default == true
                defaultAppearance = it
        return defaultAppearance

    _getAppearance: (options, config) ->
        currentAppearance = @._getDefaultAppearance(config)
        config = _.sortBy(config, (o) -> - o.days_to_due) # sort desc

        dueDate = moment(options.dueDate)
        now = moment()
        _.map config, (appearance) ->
            if appearance.days_to_due == null
                return
            limitDate = moment(dueDate - moment.duration(appearance.days_to_due, "days"))
            if now >= limitDate
                currentAppearance = appearance

        return currentAppearance

    _formatTitle: (options) ->
        prettyDate = @translate.instant("COMMON.PICKERDATE.FORMAT")
        formatedDate = moment(options.dueDate).format(prettyDate)

        status = @.getStatus(options)
        if status?.name
            return "#{formatedDate} (#{status.name})"
        return formatedDate

taiga.DueDateService = DueDateService

angular.module("taigaCommon").service("tgDueDateService", DueDateService)
