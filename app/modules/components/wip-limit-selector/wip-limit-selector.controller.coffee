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
# File: components/vote-button/vote-button.controller.coffee
###

class ProjectSwimlanesWipLimitController
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgResources",
    ]

    constructor: (@scope, @rootscope, @rs) ->
        @.new_wip_limit = @.status.wip_limit

    submitSwimlaneNewStatus: () ->
        @scope.displayWipLimitSelector = false
        if (!!@.status.swimlane_userstory_status_id)
            return @rs.swimlanes.wipLimitUpdate(@.status.swimlane_userstory_status_id, @.new_wip_limit).then () =>
                @rootscope.$broadcast("swimlane:load")
        else
            return @rs.userstories.editStatus(@.status.id, @.new_wip_limit).then () =>
                @rootscope.$broadcast("project:load")

angular.module("taigaComponents").controller("ProjectSwimlanesWipLimit", ProjectSwimlanesWipLimitController)
