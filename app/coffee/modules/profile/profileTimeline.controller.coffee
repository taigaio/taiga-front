###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/backlog/main.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

class ProfileTimelineController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgResources",
        "$tgAuth"
    ]

    constructor: (@scope, @rs, @auth) ->
        promise = @.loadTimeline()
        promise.then null, @.onInitialDataError.bind(@)

    loadTimeline: () ->
        user = @auth.getUser()

        return @rs.timeline.profile(user.id).then (result) =>
            @scope.result = result
            console.log @scope.result.data

angular.module("taigaProfile")
    .controller("ProfileTimeline", ProfileTimelineController)
