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
