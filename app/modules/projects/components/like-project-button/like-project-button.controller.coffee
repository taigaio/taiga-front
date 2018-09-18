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
# File: projects/components/like-project-button/like-project-button.controller.coffee
###

class LikeProjectButtonController
    @.$inject = [
        "$tgConfirm"
        "tgLikeProjectButtonService"
    ]

    constructor: (@confirm, @likeButtonService)->
        @.isMouseOver = false
        @.loading = false

    showTextWhenMouseIsOver: ->
        @.isMouseOver = true

    showTextWhenMouseIsLeave: ->
        @.isMouseOver = false

    toggleLike: ->
        @.loading = true

        if not @.project.get("is_fan")
            promise = @._like()
        else
            promise = @._unlike()

        promise.finally () => @.loading = false

        return promise

    _like: ->
        return @likeButtonService.like(@.project.get('id'))
            .then =>
                @.showTextWhenMouseIsLeave()
            .catch =>
                @confirm.notify("error")

    _unlike: ->
        return @likeButtonService.unlike(@.project.get('id')).catch =>
            @confirm.notify("error")

angular.module("taigaProjects").controller("LikeProjectButton", LikeProjectButtonController)
