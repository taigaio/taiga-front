###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaHistory")

class HistorySectionController
    @.$inject = [
        "$tgResources",
        "$tgRepo",
        "$tgStorage",
        "tgProjectService",
        "tgActivityService",
        "tgWysiwygService"
    ]

    constructor: (@rs, @repo, @storage, @projectService, @activityService, @wysiwygService) ->
        @.editing = null
        @.deleting = null
        @.editMode = {}
        @.viewComments = true

        @.reverse = @storage.get("orderComments")

        taiga.defineImmutableProperty @, 'disabledActivityPagination', () =>
            return @activityService.disablePagination
        taiga.defineImmutableProperty @, 'loadingActivity', () =>
            return @activityService.loading

    _loadHistory: () ->
        if @.totalComments == 0
            @.commentsNum = 0
        else
            @._loadComments()

        @._loadActivity()

    _loadActivity: () ->
        @activityService.init(@.name, @.id)
        @activityService.fetchEntries().then (response) =>
            @.activitiesNum = @activityService.count
            @.activities = response.toJS()

    _loadComments: () ->
        @rs.history.get(@.name, @.id, 'comment').then (comments) =>
            @.comments = _.filter(comments, (item) -> item.comment != "")

            if @.reverse
                @.comments - _.reverse(@.comments)
            @.commentsNum = @.comments.length

    nextActivityPage: () ->
        @activityService.nextPage().then (response) =>
            @.activities = response.toJS()

    showHistorySection: () ->
        return @.showCommentTab() or @.showActivityTab()

    showCommentTab: () ->
        return @.commentsNum > 0 or @projectService.hasPermission("comment_#{@.name}")

    showActivityTab: () ->
        return @.activitiesNum > 0

    toggleEditMode: (commentId) ->
        @.editMode[commentId] = !@.editMode[commentId]

    onActiveHistoryTab: (active) ->
        @.viewComments = active

    deleteComment: (commentId) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.deleting = commentId
        return @rs.history.deleteComment(type, objectId, activityId).then =>
            @._loadComments()
            @.deleting = null

    editComment: (commentId, comment) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.editing = commentId
        return @rs.history.editComment(type, objectId, activityId, comment).then =>
            @._loadComments()
            @.toggleEditMode(commentId)
            @.editing = null

    restoreDeletedComment: (commentId) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.editing = commentId
        return @rs.history.undeleteComment(type, objectId, activityId).then =>
            @._loadComments()
            @.editing = null

    addComment: () ->
        @.editMode = {}
        @.editing = null
        @._loadComments()

    onOrderComments: () ->
        @.reverse = !@.reverse
        @storage.set("orderComments", @.reverse)
        @._loadComments()

module.controller("HistorySection", HistorySectionController)
