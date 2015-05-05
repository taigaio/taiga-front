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


HistoryDirective = ($log, $loading, $qqueue, $template, $confirm, $translate, $compile) ->
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

        getPrettyDateFormat = ->
            return $translate.instant("ACTIVITY.DATETIME")

        bindOnce $scope, $attrs.ngModel, (model) ->
            type = $attrs.type
            objectId = model.id

            $ctrl.initialize(type, objectId)
            $ctrl.loadHistory(type, objectId)

        # Helpers
        getHumanizedFieldName = (field) ->
            humanizedFieldNames = {
                subject :              $translate.instant("ACTIVITY.FIELDS.SUBJECT")
                name:                  $translate.instant("ACTIVITY.FIELDS.NAME")
                description :          $translate.instant("ACTIVITY.FIELDS.DESCRIPTION")
                content:               $translate.instant("ACTIVITY.FIELDS.CONTENT")
                status:                $translate.instant("ACTIVITY.FIELDS.STATUS")
                is_closed :            $translate.instant("ACTIVITY.FIELDS.IS_CLOSED")
                finish_date :          $translate.instant("ACTIVITY.FIELDS.FINISH_DATE")
                type:                  $translate.instant("ACTIVITY.FIELDS.TYPE")
                priority:              $translate.instant("ACTIVITY.FIELDS.PRIORITY")
                severity:              $translate.instant("ACTIVITY.FIELDS.SEVERITY")
                assigned_to :          $translate.instant("ACTIVITY.FIELDS.ASSIGNED_TO")
                watchers :             $translate.instant("ACTIVITY.FIELDS.WATCHERS")
                milestone :            $translate.instant("ACTIVITY.FIELDS.MILESTONE")
                user_story:            $translate.instant("ACTIVITY.FIELDS.USER_STORY")
                project:               $translate.instant("ACTIVITY.FIELDS.PROJECT")
                is_blocked:            $translate.instant("ACTIVITY.FIELDS.IS_BLOCKED")
                blocked_note:          $translate.instant("ACTIVITY.FIELDS.BLOCKED_NOTE")
                points:                $translate.instant("ACTIVITY.FIELDS.POINTS")
                client_requirement :   $translate.instant("ACTIVITY.FIELDS.CLIENT_REQUIREMENT")
                team_requirement :     $translate.instant("ACTIVITY.FIELDS.TEAM_REQUIREMENT")
                is_iocaine:            $translate.instant("ACTIVITY.FIELDS.IS_IOCAINE")
                tags:                  $translate.instant("ACTIVITY.FIELDS.TAGS")
                attachments :          $translate.instant("ACTIVITY.FIELDS.ATTACHMENTS")
                is_deprecated:         $translate.instant("ACTIVITY.FIELDS.IS_DEPRECATED")
                blocked_note:          $translate.instant("ACTIVITY.FIELDS.BLOCKED_NOTE")
                is_blocked:            $translate.instant("ACTIVITY.FIELDS.IS_BLOCKED")
                order:                 $translate.instant("ACTIVITY.FIELDS.ORDER")
                backlog_order:         $translate.instant("ACTIVITY.FIELDS.BACKLOG_ORDER")
                sprint_order:          $translate.instant("ACTIVITY.FIELDS.SPRINT_ORDER")
                kanban_order:          $translate.instant("ACTIVITY.FIELDS.KANBAN_ORDER")
                taskboard_order:       $translate.instant("ACTIVITY.FIELDS.TASKBOARD_ORDER")
                us_order:              $translate.instant("ACTIVITY.FIELDS.US_ORDER")
            }

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
                    return $translate.instant("ACTIVITY.VALUES.EMPTY")
                return change.join(", ")

            if change == ""
                return $translate.instant("ACTIVITY.VALUES.EMPTY")

            if not change? or change == false
                return $translate.instant("ACTIVITY.VALUES.NO")

            if change == true
                return $translate.instant("ACTIVITY.VALUES.YES")

            return change

        # Render into string (operations without mutability)

        renderAttachmentEntry = (value) ->
            attachments = _.map value, (changes, type) ->
                if type == "new"
                    return _.map changes, (change) ->
                        return templateChangeDiff({
                            name: $translate.instant("ACTIVITY.NEW_ATTACHMENT"),
                            diff: change.filename
                        })
                else if type == "deleted"
                    return _.map changes, (change) ->
                        return templateChangeDiff({
                            name: $translate.instant("ACTIVITY.DELETED_ATTACHMENT"),
                            diff: change.filename
                        })
                else
                    return _.map changes, (change) ->
                        name = $translate.instant("ACTIVITY.UPDATED_ATTACHMENT", {filename: change.filename})

                        diff = _.map change.changes, (values, name) ->
                            return {
                                name: getHumanizedFieldName(name)
                                from: formatChange(values[0])
                                to: formatChange(values[1])
                            }

                        return templateChangeAttachment({name: name, diff: diff})

            return _.flatten(attachments).join("\n")

        renderCustomAttributesEntry = (value) ->
            customAttributes = _.map value, (changes, type) ->
                if type == "new"
                    return _.map changes, (change) ->
                        html = templateChangeGeneric({
                            name: change.name,
                            from: formatChange(""),
                            to: formatChange(change.value)
                        })

                        html = $compile(html)($scope)

                        return html[0].outerHTML
                else if type == "deleted"
                    return _.map changes, (change) ->
                        return templateChangeDiff({
                            name: $translate.instant("ACTIVITY.DELETED_CUSTOM_ATTRIBUTE")
                            diff: change.name
                        })
                else
                    return _.map changes, (change) ->
                        customAttrsChanges = _.map change.changes, (values) ->
                            return templateChangeGeneric({
                                name: change.name
                                from: formatChange(values[0])
                                to: formatChange(values[1])
                            })
                        return _.flatten(customAttrsChanges).join("\n")

            return _.flatten(customAttributes).join("\n")

        renderChangeEntry = (field, value) ->
            if field == "description"
                return templateChangeDiff({name: getHumanizedFieldName("description"), diff: value[1]})
            else if field == "blocked_note"
                return templateChangeDiff({name: getHumanizedFieldName("blocked_note"), diff: value[1]})
            else if field == "points"
                html = templateChangePoints({points: value})

                html = $compile(html)($scope)

                return html[0].outerHTML
            else if field == "attachments"
                return renderAttachmentEntry(value)
            else if field == "custom_attributes"
                return renderCustomAttributesEntry(value)
            else if field in ["tags", "watchers"]
                name = getHumanizedFieldName(field)
                removed = _.difference(value[0], value[1])
                added = _.difference(value[1], value[0])
                html = templateChangeList({name:name, removed:removed, added: added})

                html = $compile(html)($scope)

                return html[0].outerHTML
            else if field == "assigned_to"
                name = getHumanizedFieldName(field)
                from = formatChange(value[0] or $translate.instant("ACTIVITY.VALUES.UNASSIGNED"))
                to = formatChange(value[1] or $translate.instant("ACTIVITY.VALUES.UNASSIGNED"))
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
            return $translate.instant("ACTIVITY.SIZE_CHANGE", {size: size}, 'messageformat')

        renderComment = (comment) ->
            if (comment.delete_comment_date or comment.delete_comment_user?.name)
                html = templateDeletedComment({
                    deleteCommentDate: moment(comment.delete_comment_date).format(getPrettyDateFormat()) if comment.delete_comment_date
                    deleteCommentUser: comment.delete_comment_user.name
                    deleteComment: comment.comment_html
                    activityId: comment.id
                    canRestoreComment: (comment.delete_comment_user.pk == $scope.user.id or
                                        $scope.project.my_permissions.indexOf("modify_project") > -1)
                })

                html = $compile(html)($scope)

                return html[0].outerHTML

            html = templateActivity({
                avatar: getUserAvatar(comment.user.pk)
                userFullName: comment.user.name
                creationDate: moment(comment.created_at).format(getPrettyDateFormat())
                comment: comment.comment_html
                changesText: renderChangesHelperText(comment)
                changes: renderChangeEntries(comment)
                mode: "comment"
                deleteCommentDate: moment(comment.delete_comment_date).format(getPrettyDateFormat()) if comment.delete_comment_date
                deleteCommentUser: comment.delete_comment_user.name if comment.delete_comment_user?.name
                activityId: comment.id
                canDeleteComment: comment.user.pk == $scope.user?.id or $scope.project.my_permissions.indexOf("modify_project") > -1
            })

            html = $compile(html)($scope)

            return html[0].outerHTML

        renderChange = (change) ->
            return templateActivity({
                avatar: getUserAvatar(change.user.pk)
                userFullName: change.user.name
                creationDate: moment(change.created_at).format(getPrettyDateFormat())
                comment: change.comment_html
                changes: renderChangeEntries(change)
                changesText: ""
                mode: "activity"
                deleteCommentDate: moment(change.delete_comment_date).format(getPrettyDateFormat()) if change.delete_comment_date
                deleteCommentUser: change.delete_comment_user.name if change.delete_comment_user?.name
                activityId: change.id
            })

        renderHistory = (entries, totalEntries) ->
            if entries.length == totalEntries
                showMore = 0
            else
                showMore = totalEntries - entries.length

            html = templateBaseEntries({entries: entries, showMore:showMore})
            html = $compile(html)($scope)
            return html

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
        html = templateBase({ngmodel: $attrs.ngModel, type: $attrs.type, mode: $attrs.mode})

        return html

    return {
        controller: HistoryController
        template: templateFn
        restrict: "AE"
        link: link
        # require: ["ngModel", "tgHistory"]
    }


module.directive("tgHistory", ["$log", "$tgLoading", "$tgQqueue", "$tgTemplate", "$tgConfirm", "$translate",
                               "$compile", HistoryDirective])
