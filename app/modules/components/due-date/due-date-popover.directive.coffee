###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaComponents")

dueDatePopoverDirective = ($translate, datePickerConfigService) ->
    return {
        link: (scope, el, attrs, ctrl) ->
            scope.open = false

            datePickerConfig = datePickerConfigService.get()
            _.merge(datePickerConfig, {
                field: el.find('.due-date-button')[0]
                container: el.find('.date-picker-container')[0]
                bound: true
                onClose: () ->
                    scope.open = false
                    scope.$apply()
                onSelect: () ->
                    ctrl.dueDate = this.getMoment().format('YYYY-MM-DD')
            })
            el.picker = new Pikaday(datePickerConfig)

            el.on "click", ".due-date-button", (event) ->
                event.preventDefault()
                event.stopPropagation()
                if scope.open
                    el.picker.hide()
                    return
                if !el.picker.getDate() && ctrl.dueDate
                    el.picker.setDate(moment(ctrl.dueDate).format('YYYY-MM-DD'))
                el.picker.show()
                scope.open = true
                scope.$apply()

            el.on "click", ".date-picker-clean", (event) ->
                event.preventDefault()
                event.stopPropagation()
                ctrl.dueDate = null
                el.picker.setDate(ctrl.dueDate)
                scope.open = false
                el.picker.hide()
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
            objType: '@',
            format: '@',
            notAutoSave: '='
        }
    }

module.directive('tgDueDatePopover', ['$translate', 'tgDatePickerConfigService', dueDatePopoverDirective])