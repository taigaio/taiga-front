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
# File: modules/common/history.coffee
###

taiga = @.taiga
trim = @.taiga.trim
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaCommon")


#############################################################################
## History Directive (Main)
#############################################################################


class HistoryController extends taiga.Controller
    @.$inject = ["$scope", "$tgRepo", "$tgResources"]

    constructor: (@scope, @repo, @rs) ->

    initialize: (type, objectId) ->
        @.type = type
        @.objectId = objectId

    loadHistory: (type, objectId) ->
        return @rs.history.get(type, objectId).then (history) =>
            for historyResult in history
                # If description was modified take only the description_html field
                if historyResult.values_diff.description_diff?
                    historyResult.values_diff.description = historyResult.values_diff.description_diff

                delete historyResult.values_diff.description_html
                delete historyResult.values_diff.description_diff

                # If block note was modified take only the blocked_note_html field
                if historyResult.values_diff.blocked_note_diff?
                    historyResult.values_diff.blocked_note = historyResult.values_diff.blocked_note_diff

                delete historyResult.values_diff.blocked_note_html
                delete historyResult.values_diff.blocked_note_diff

            @scope.history = history
            @scope.comments = _.filter(history, (item) -> item.comment != "")

    deleteComment: (type, objectId, activityId) ->
        return @rs.history.deleteComment(type, objectId, activityId).then => @.loadHistory(type, objectId)

    undeleteComment: (type, objectId, activityId) ->
        return @rs.history.undeleteComment(type, objectId, activityId).then => @.loadHistory(type, objectId)


HistoryDirective = ($log, $loading, $qqueue, $template, $confirm) ->
    templateChangeDiff = $template.get("common/history/history-change-diff.html", true)
    templateChangePoints = $template.get("common/history/history-change-points.html", true)
    templateChangeGeneric = $template.get("common/history/history-change-generic.html", true)
    templateChangeAttachment = $template.get("common/history/history-change-attachment.html", true)
    templateChangeList = $template.get("common/history/history-change-list.html", true)
    templateDeletedComment = $template.get("common/history/history-deleted-comment.html", true)
    templateActivity = $template.get("common/history/history-activity.html", true)
    templateBaseEntries = $template.get("common/history/history-base-entries.html", true)
    templateBase = $template.get("common/history/history-base.html", true)

    link = ($scope, $el, $attrs, $ctrl) ->
        # Bootstraping
        type = $attrs.type
        objectId = null

        showAllComments = false
        showAllActivity = false

        bindOnce $scope, $attrs.ngModel, (model) ->
            type = $attrs.type
            objectId = model.id

            $ctrl.initialize(type, objectId)
            $ctrl.loadHistory(type, objectId)

        # Helpers
        getHumanizedFieldName = (field) ->
            humanizedFieldNames = {
                # US
                assigned_to: "assigned to"
                is_closed: "is closed"
                finish_date: "finish date"
                client_requirement: "client requirement"
                team_requirement: "team requirement"

                # Task
                milestone: "sprint"
                user_story: "user story"
                is_iocaine: "is iocaine"

                # Attachment
                is_deprecated: "is deprecated"

                blocked_note: "blocked note"
                is_blocked: "is blocked"
            } # TODO i18n
            return humanizedFieldNames[field] or field

        getUserFullName = (userId) ->
            return $scope.usersById[userId]?.full_name_display

        getUserAvatar = (userId) ->
            if $scope.usersById[userId]?
                return $scope.usersById[userId].photo
            else
                return "/images/unnamed.png"

        countChanges = (comment) ->
            return _.keys(comment.values_diff).length

        formatChange = (change) ->
            if _.isArray(change)
                if change.length == 0
                    return "empty"
                return change.join(", ")

            if change == ""
                return "empty"

            if not change? or change == false
                return "no"

            if change == true
                return "yes"

            return change

        # Render into string (operations without mutability)

        renderAttachmentEntry = (value) ->
            attachments = _.map value, (changes, type) ->
                if type == "new"
                    return _.map changes, (change) ->
                        # TODO: i18n
                        return templateChangeDiff({name: "new attachment", diff: change.filename})
                else if type == "deleted"
                    return _.map changes, (change) ->
                        # TODO: i18n
                        return templateChangeDiff({name: "deleted attachment", diff: change.filename})
                else
                    return _.map changes, (change) ->
                        # TODO: i18n
                        name = "updated attachment #{change.filename}"
                        diff = _.map change.changes, (values, name) ->
                            return {
                                name: getHumanizedFieldName(name)
                                from: formatChange(values[0])
                                to: formatChange(values[1])
                                }

                        return templateChangeAttachment({name: name, diff: diff})

            return _.flatten(attachments).join("\n")

        renderChangeEntry = (field, value) ->
            if field == "description"
                return templateChangeDiff({name: getHumanizedFieldName("description"), diff: value[1]})
            else if field == "blocked_note"
                return templateChangeDiff({name: getHumanizedFieldName("blocked_note"), diff: value[1]})
            else if field == "points"
                return templateChangePoints({points: value})
            else if field == "attachments"
                return renderAttachmentEntry(value)
            else if field in ["tags", "watchers"]
                name = getHumanizedFieldName(field)
                removed = _.difference(value[0], value[1])
                added = _.difference(value[1], value[0])
                return templateChangeList({name:name, removed:removed, added: added})
            else if field == "assigned_to"
                name = getHumanizedFieldName(field)
                from = formatChange(value[0] or "Unassigned")
                to = formatChange(value[1] or "Unassigned")
                return templateChangeGeneric({name:name, from:from, to: to})
            else
                name = getHumanizedFieldName(field)
                from = formatChange(value[0])
                to = formatChange(value[1])
                return templateChangeGeneric({name:name, from:from, to: to})

        renderChangeEntries = (change) ->
            return _.map(change.values_diff, (value, field) -> renderChangeEntry(field, value))

        renderChangesHelperText = (change) ->
            size = countChanges(change)
            if size == 1
                return "Made #{size} change" # TODO: i18n
            return "Made #{size} changes" # TODO: i18n

        renderComment = (comment) ->
            if (comment.delete_comment_date or comment.delete_comment_user?.name)
                return templateDeletedComment({
                    deleteCommentDate: moment(comment.delete_comment_date).format("DD MMM YYYY HH:mm") if comment.delete_comment_date
                    deleteCommentUser: comment.delete_comment_user.name
                    deleteComment: comment.comment_html
                    activityId: comment.id
                    canRestoreComment: comment.delete_comment_user.pk == $scope.user.id or $scope.project.my_permissions.indexOf("modify_project") > -1
                })

            return templateActivity({
                avatar: getUserAvatar(comment.user.pk)
                userFullName: comment.user.name
                creationDate: moment(comment.created_at).format("DD MMM YYYY HH:mm")
                comment: comment.comment_html
                changesText: renderChangesHelperText(comment)
                changes: renderChangeEntries(comment)
                mode: "comment"
                deleteCommentDate: moment(comment.delete_comment_date).format("DD MMM YYYY HH:mm") if comment.delete_comment_date
                deleteCommentUser: comment.delete_comment_user.name if comment.delete_comment_user?.name
                activityId: comment.id
                canDeleteComment: comment.user.pk == $scope.user.id or $scope.project.my_permissions.indexOf("modify_project") > -1
            })

        renderChange = (change) ->
            return templateActivity({
                avatar: getUserAvatar(change.user.pk)
                userFullName: change.user.name
                creationDate: moment(change.created_at).format("DD MMM YYYY HH:mm")
                comment: change.comment_html
                changes: renderChangeEntries(change)
                changesText: ""
                mode: "activity"
                deleteCommentDate: moment(change.delete_comment_date).format("DD MMM YYYY HH:mm") if change.delete_comment_date
                deleteCommentUser: change.delete_comment_user.name if change.delete_comment_user?.name
                activityId: change.id
            })

        renderHistory = (entries, totalEntries) ->
            if entries.length == totalEntries
                showMore = 0
            else
                showMore = totalEntries - entries.length

            return templateBaseEntries({entries: entries, showMore:showMore})

        # Render into DOM (operations with dom mutability)

        renderComments = ->
            comments = $scope.comments or []
            totalComments = comments.length
            if not showAllComments
                comments = _.last(comments, 4)

            comments = _.map(comments, (x) -> renderComment(x))
            html = renderHistory(comments, totalComments)
            $el.find(".comments-list").html(html)

        renderActivity = ->
            changes = $scope.history or []
            totalChanges = changes.length
            if not showAllActivity
                changes = _.last(changes, 4)

            changes = _.map(changes, (x) -> renderChange(x))
            html = renderHistory(changes, totalChanges)
            $el.find(".changes-list").html(html)

        save = $qqueue.bindAdd (target) =>
            $scope.$broadcast("markdown-editor:submit")

            $el.find(".comment-list").addClass("activeanimation")

            onSuccess = ->
                $ctrl.loadHistory(type, objectId).finally ->
                    $loading.finish(target)

            onError = ->
                $loading.finish(target)
                $confirm.notify("error")

            model = $scope.$eval($attrs.ngModel)
            $loading.start(target)

            $ctrl.repo.save(model).then(onSuccess, onError)

        # Watchers

        $scope.$watch("comments", renderComments)
        $scope.$watch("history",  renderActivity)

        $scope.$on("history:reload", -> $ctrl.loadHistory(type, objectId))

        # Events

        $el.on "click", ".add-comment a.button-green", debounce 2000, (event) ->
            event.preventDefault()

            target = angular.element(event.currentTarget)

            save(target)

        $el.on "click", ".show-more", (event) ->
            event.preventDefault()

            target = angular.element(event.currentTarget)
            if target.parent().is(".changes-list")
                showAllActivity = not showAllActivity
                renderActivity()
            else
                showAllComments = not showAllComments
                renderComments()

        $el.on "click", ".show-deleted-comment", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.parents('.activity-single').find('.hide-deleted-comment').show()
            target.parents('.activity-single').find('.show-deleted-comment').hide()
            target.parents('.activity-single').find('.comment-body').show()

        $el.on "click", ".hide-deleted-comment", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.parents('.activity-single').find('.hide-deleted-comment').hide()
            target.parents('.activity-single').find('.show-deleted-comment').show()
            target.parents('.activity-single').find('.comment-body').hide()

        $el.on "click", ".changes-title", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.parent().find(".change-entry").toggleClass("active")

        $el.on "focus", ".add-comment textarea", (event) ->
            $(this).addClass('active')

        $el.on "click", ".history-tabs li a", (event) ->
            $el.find(".history-tabs li a").toggleClass("active")
            $el.find(".history section").toggleClass("hidden")

        $el.on "click", ".comment-delete", debounce 2000, (event) ->
            event.preventDefault()

            target = angular.element(event.currentTarget)
            activityId = target.data('activity-id')
            $ctrl.deleteComment(type, objectId, activityId)

        $el.on "click", ".comment-restore", debounce 2000, (event) ->
            event.preventDefault()

            target = angular.element(event.currentTarget)
            activityId = target.data('activity-id')
            $ctrl.undeleteComment(type, objectId, activityId)

        $scope.$on "$destroy", ->
            $el.off()

    templateFn = ($el, $attrs) ->
        return templateBase({ngmodel: $attrs.ngModel, type: $attrs.type, mode: $attrs.mode})

    return {
        controller: HistoryController
        template: templateFn
        restrict: "AE"
        link: link
        # require: ["ngModel", "tgHistory"]
    }


module.directive("tgHistory", ["$log", "$tgLoading", "$tgQqueue", "$tgTemplate", "$tgConfirm", HistoryDirective])
