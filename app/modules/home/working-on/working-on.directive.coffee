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
# File: home/working-on/working-on.directive.coffee
###

taiga = @.taiga

generateHash = @.taiga.generateHash

WorkingOnDirective = (homeService, currentUserService, storage) ->
        
    link = (scope, el, attrs, ctrl) ->
        updateShowHiddenDuties = (slot) ->
            hash = generateHash(['ShowHiddenDashboardDuties', slot])
            return storage.set(hash, scope.showHiddenDuties[slot])

        getShowHiddenDuties = (slot) ->
            hash = generateHash(['ShowHiddenDashboardDuties', slot])
            return storage.get(hash) or false

        updateHiddenDuties = (slot) ->
            hash = generateHash(['HiddenDashboardDuties', slot])
            return storage.set(hash, scope.hiddenDuties[slot])

        getHiddenDuties = (slot) ->
            hash = generateHash(['HiddenDashboardDuties', slot])
            return storage.get(hash) or []

        toggleDutyHidden = (duty, slot) ->
            if duty.get('id') in scope.hiddenDuties[slot]
                scope.hiddenDuties[slot].splice(scope.hiddenDuties[slot].indexOf(duty.get('id')), 1)
            else
                scope.hiddenDuties[slot].push(duty.get('id'))
            updateHiddenDuties(slot)
            scope.$apply()

        user = currentUserService.getUser()
        # If we are not logged in the user will be null
        if !user
            return

        userId = user.get("id")
        ctrl.getWorkInProgress(userId)

        slots = ['working-on', 'watching']

        scope.hiddenDuties = {}
        scope.showHiddenDuties = {}

        scope.toggleShowHiddenDuties = (slot) ->
            if !(slot in slots)
                return console.error("Invalid duties slot `#{slot}`")
            scope.showHiddenDuties[slot] = !scope.showHiddenDuties[slot]
            updateShowHiddenDuties(slot)

        for slot in slots
            scope.hiddenDuties[slot] =  getHiddenDuties(slot)
            scope.showHiddenDuties[slot] =  getShowHiddenDuties(slot)

        scope.$on "duty:toggle-hidden", (event, duty, slot) =>
            if !(slot in slots)
                return console.error("Invalid duties slot `#{slot}`")
            toggleDutyHidden(duty, slot)

    return {
        controller: "WorkingOn",
        controllerAs: "vm",
        templateUrl: "home/working-on/working-on.html",
        scope: {},
        link: link
    }

WorkingOnDirective.$inject = [
    "tgHomeService",
    "tgCurrentUserService",
    "$tgStorage"
]

angular.module("taigaHome").directive("tgWorkingOn", WorkingOnDirective)
