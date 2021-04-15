###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
