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
# File: history/history.controller.coffee
###

module = angular.module("taigaHistory")

class HistorySectionController
    @.$inject = [
        "$tgResources",
        "$tgRepo",
        "$tgStorage",
        "tgProjectService",
    ]

    constructor: (@rs, @repo, @storage, @projectService) ->
        @.editing = null
        @.deleting = null
        @.editMode = {}
        @.viewComments = true
        @.reverse = @storage.get("orderComments")
        @._loadHistory()

    _loadHistory: () ->
        @rs.history.get(@.name, @.id).then (history) =>
            @._getComments(history)
            @._getActivities(history)

    _getComments: (comments) ->
        @.comments = _.filter(comments, (item) -> item.comment != "")
        if @.reverse
            @.comments - _.reverse(@.comments)
        @.commentsNum = @.comments.length

    _getActivities: (activities) ->
        @.activities =  _.filter(activities, (item) -> Object.keys(item.values_diff).length > 0)
        @.activitiesNum = @.activities.length

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
            @._loadHistory()
            @.deleting = null

    editComment: (commentId, comment) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.editing = commentId
        return @rs.history.editComment(type, objectId, activityId, comment).then =>
            @._loadHistory()
            @.toggleEditMode(commentId)
            @.editing = null

    restoreDeletedComment: (commentId) ->
        type = @.name
        objectId = @.id
        activityId = commentId
        @.editing = commentId
        return @rs.history.undeleteComment(type, objectId, activityId).then =>
            @._loadHistory()
            @.editing = null

    addComment: (cb) ->
        return @repo.save(@.type).then =>
            @._loadHistory()
            cb()

    onOrderComments: () ->
        @.reverse = !@.reverse
        @storage.set("orderComments", @.reverse)
        @._loadHistory()

module.controller("HistorySection", HistorySectionController)
