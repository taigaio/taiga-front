###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
