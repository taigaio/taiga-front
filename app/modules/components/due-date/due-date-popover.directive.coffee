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
# File: due-date.directive.coffee
###

module = angular.module("taigaComponents")

dueDatePopoverDirective = ($translate, datePickerConfigService) ->
    return {
        link: (scope, el, attrs, ctrl) ->
            datePickerConfig = datePickerConfigService.get()
            _.merge(datePickerConfig, {
                field: el.find('input.due-date')[0]
                container: el.find('.date-picker-container')[0]
                bound: false
                onSelect: () ->
                    ctrl.dueDate = this.getMoment().format('YYYY-MM-DD')
                    el.find(".date-picker-popover").popover().close()
                    scope.$apply()
            })
            el.picker = new Pikaday(datePickerConfig)

            el.on "click", ".date-picker-popover-trigger", (event) ->
                if ctrl.disabled()
                    return
                event.preventDefault()
                event.stopPropagation()
                if !el.picker.getDate()
                    el.picker.setDate(moment(ctrl.dueDate).format('YYYY-MM-DD'))
                el.find(".date-picker-popover").popover().open()

            el.on "click", ".date-picker-clean", (event) ->
                event.preventDefault()
                event.stopPropagation()
                ctrl.dueDate = null
                el.picker.setDate(ctrl.dueDate)
                el.find(".date-picker-popover").popover().close()
                scope.$apply()

            scope.$on "status:changed", (ctx, status) ->
                ctrl.isClosed = ctrl.item.is_closed

        controller: "DueDateCtrl",
        controllerAs: "vm",
        bindToController: true,
        templateUrl: "components/due-date/due-date-popover.html",
        scope: {
            dueDate: '=',
            isClosed: '=',
            item: '=',
            format: '@',
            notAutoSave: '='
        }
    }

module.directive('tgDueDatePopover', ['$translate', 'tgDatePickerConfigService', dueDatePopoverDirective])