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
# File: components/assigned-to/assigned-to.controller.coffee
###

class AssignedToController
    @.$inject = [
        "tgLightboxFactory",
        "lightboxService",
    ]

    constructor: (@lightboxFactory, @lightboxService) ->
        @.has_permissions = _.includes(@.project.my_permissions, 'modify_epic')

    _closeAndRemoveAssigned: () ->
        @lightboxService.closeAll()
        @.onRemoveAssigned()

    _closeAndAssign: (member) ->
        @lightboxService.closeAll()
        @.onAssignTo({'member': member})

    onSelectAssignedTo: (assigned, project) ->
        @lightboxFactory.create('tg-assigned-to-selector', {
            "class": "lightbox lightbox-assigned-to-selector open",
            "assigned": "assigned",
            "project": "project",
            "on-remove-assigned": "onRemoveAssigned()"
            "on-assign-to": "assignTo(member)"
        }, {
            "assigned": @.assignedTo,
            "project": @.project,
            "onRemoveAssigned": @._closeAndRemoveAssigned.bind(this),
            "assignTo": @._closeAndAssign.bind(this)
        })

angular.module('taigaComponents').controller('AssignedToCtrl', AssignedToController)
