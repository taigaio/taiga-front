###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

    showDeletedComment: () ->
        @.hiddenDeletedComment = false

    hideDeletedComment: () ->
        @.hiddenDeletedComment = true

    checkCancelComment: (event) ->
        if event.keyCode == 27
            @.onEditMode({commentId: @.comment.id})

    canEditDeleteComment: () ->
        if @currentUserService.getUser()
            @.user = @currentUserService.getUser()
            return @.user.get('id') == @.comment.user.pk || @permissionService.check('modify_project')

    saveComment: (text, cb) ->
        @.onEditComment({commentId: @.comment.id, commentData: text, callback: cb})

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
