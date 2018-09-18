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
# File: components/due-date/due-date-controller.coffee
###

class DueDateController
    @.$inject = [
        "$translate"
        "tgLightboxFactory"
        "tgProjectService"
        "$rootScope"
    ]

    constructor: (@translate, @tgLightboxFactory, @projectService,  @rootscope) ->
        @.defaultConfig = [
            {"color": "#9dce0a", "name": "normal due", "days_to_due": null, "by_default": true},
            {"color": "#ff9900", "name": "due soon", "days_to_due": 14, "by_default": false},
            {"color": "#ff8a84", "name": "past due", "days_to_due": 0, "by_default": false}
        ]

    visible: () ->
        return @.format == 'button' or @.dueDate?

    disabled: () ->
        return @.isClosed

    color: () ->
        return @.getStatus()?.color || null

    title: () ->
        if @.dueDate
            return @._formatTitle()
        else if @.format == 'button'
            return @translate.instant('COMMON.DUE_DATE.TITLE_ACTION_SET_DUE_DATE')
        return ''

    getStatus: (options) ->
        if !@.dueDate
            return null

        project = @projectService.project.toJS()
        options = project["#{@.objType}_duedates"]

        if !options
            options = @.defaultConfig

        return @._getAppearance(options)

    _getDefaultAppearance: (options) ->
        defaultAppearance = null
        _.map options, (option) ->
            if option.by_default == true
                defaultAppearance = option
        return defaultAppearance

    _getAppearance: (options) ->
        currentAppearance = @._getDefaultAppearance(options)
        options = _.sortBy(options, (o) -> - o.days_to_due) # sort desc

        dueDate = moment(@.dueDate)
        now = moment()
        _.map options, (appearance) ->
            if appearance.days_to_due == null
                return
            limitDate = moment(dueDate - moment.duration(appearance.days_to_due, "days"))
            if now >= limitDate
                currentAppearance = appearance

        return currentAppearance

    _formatTitle: () ->
        prettyDate = @translate.instant("COMMON.PICKERDATE.FORMAT")
        formatedDate = moment(@.dueDate).format(prettyDate)

        status = @.getStatus()
        if status?.name
            return "#{formatedDate} (#{status.name})"
        return formatedDate

    setDueDate: () ->
        return if @.disabled()
        @tgLightboxFactory.create(
            "tg-lb-set-due-date",
            {"class": "lightbox lightbox-set-due-date"},
            {"object": @.item, "notAutoSave": @.notAutoSave}
        )

angular.module('taigaComponents').controller('DueDateCtrl', DueDateController)
