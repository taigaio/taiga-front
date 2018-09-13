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
# File: history/history/history-diff.controller.coffee
###

module = angular.module("taigaHistory")

class ActivitiesDiffController
    @.$inject = [
    ]

    constructor: () ->

    diffTags: () ->
        if @.type == 'tags'
            @.diffRemoveTags = _.difference(@.diff[0], @.diff[1]).toString()
            @.diffAddTags = _.difference(@.diff[1], @.diff[0]).toString()


module.controller("ActivitiesDiffCtrl", ActivitiesDiffController)
