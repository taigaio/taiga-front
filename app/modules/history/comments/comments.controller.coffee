module = angular.module("taigaHistory")

class CommentsController
    @.$inject = []

    constructor: () ->

    initializePermissions: () ->
        @.canAddCommentPermission = 'comment_' + @.name

module.controller("CommentsCtrl", CommentsController)
