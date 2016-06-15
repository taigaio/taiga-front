###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: history.controller.coffee
###

module = angular.module("taigaHistory")

class CommentController
    @.$inject = [
        "tgCurrentUserService",
        "tgCheckPermissionsService",
        "tgLightboxFactory"
    ]

    constructor: (@currentUserService, @permissionService, @lightboxFactory) ->
        @.hiddenDeletedComment = true
        @.toggleEditComment = false
        @.commentContent = angular.copy(@.comment)

    showDeletedComment: () ->
        @.hiddenDeletedComment = false

    hideDeletedComment: () ->
        @.hiddenDeletedComment = true

    toggleCommentEditor: () ->
        @.toggleEditComment = !@.toggleEditComment

    checkCancelComment: (event) ->
        if event.keyCode == 27
            @.toggleCommentEditor()

    canEditDeleteComment: () ->
        if @currentUserService.getUser()
            @.user = @currentUserService.getUser()
            return @.user.get('id') == @.comment.user.pk || @permissionService.check('modify_project')

    displayCommentHistory: () ->
        @lightboxFactory.create('tg-lb-display-historic', {
            "class": "lightbox lightbox-display-historic"
            "comment": "comment"
            "name": "name"
            "object": "object"
        }, {
            "comment": @.comment
            "name": @.name
            "object": @.object
        })

module.controller("CommentCtrl", CommentController)
