###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
