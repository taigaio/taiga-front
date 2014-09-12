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

module = angular.module("taigaCommon")

#############################################################################
## History Directive (Main)
#############################################################################

class HistoryController extends taiga.Controller
    @.$inject = ["$scope", "$tgRepo"]

    constructor: (@scope, @repo) ->

    initialize: (type, objectId) ->
        @.type = type
        @.objectId = objectId

    getHistory: (type, objectId) ->
        return @repo.queryOneRaw("history/#{type}", objectId)

    loadHistory: ->
        return @.getHistory(@.type, @.objectId).then (history) =>
            for historyResult in history
                # If description was modified take only the description_html field
                if historyResult.values_diff.description_diff?
                    historyResult.values_diff.description = historyResult.values_diff.description_diff

                delete historyResult.values_diff.description_html
                delete historyResult.values_diff.description_diff

            @scope.history = history
            @scope.comments = _.filter(history, (item) -> item.comment != "")


HistoryDirective = ($log) ->
    templateChangeDiff = _.template("""
    <div class="change-entry">
        <div class="activity-changed">
            <span><%- name %></span>
        </div>
        <div class="activity-fromto">
            <p>
                <span><%= diff %></span>
            </p>
        </div>
    </div>
    """)

    templateChangePoints = _.template("""
    <% _.each(points, function(point, name) { %>
    <div class="change-entry">
        <div class="activity-changed">
            <span>points (<%- name.toLowerCase() %>)</span>
        </div>
        <div class="activity-fromto">
            <p>
                <strong> from </strong> <br />
                <span><%= point[0] %></span>
            </p>
            <p>
                <strong> to </strong> <br />
                <span><%= point[1] %></span>
            </p>
        </div>
    </div>
    <% }); %>
    """)

    templateChangeGeneric = _.template("""
    <div class="change-entry">
        <div class="activity-changed">
            <span><%- name %></span>
        </div>
        <div class="activity-fromto">
            <p>
                <strong> from </strong> <br />
                <span><%= from %></span>
            </p>
            <p>
                <strong> to </strong> <br />
                <span><%= to %></span>
            </p>
        </div>
    </div>
    """)

    templateActivity = _.template("""
    <div class="activity-single <%- mode %>">
        <div class="activity-user">
            <a class="avatar" href="" title="<%- userFullName %>">
                <img src="<%- avatar %>" alt="<%- userFullName %>">
            </a>
        </div>
        <div class="activity-content">
            <div class="activity-username">
                <a class="username" href="" title="<%- userFullName %>">
                    <%- userFullName %>
                </a>
                <span class="date">
                    <%- creationDate %>
                </span>
            </div>

            <% if (comment.length > 0) { %>
            <div class="comment wysiwyg">
                <%= comment %>
            </div>
            <% } %>

            <% if(changes.length > 0) { %>
            <div class="changes">
                <% if (mode != "activity") { %>
                <a class="changes-title" href="" title="Show activity">
                  <span><%- changesText %></span>
                  <span class="icon icon-arrow-up"></span>
                </a>
                <% } %>

                <% _.each(changes, function(change) { %>
                    <%= change %>
                <% }) %>
            </div>
            <% } %>
        </div>
    </div>
    """)

    templateBaseEntries = _.template("""
    <% if (showMore > 0) { %>
    <a href="" title="Show more" class="show-more show-more-comments">
    + Show previous entries (<%- showMore %> more)
    </a>
    <% } %>
    <% _.each(entries, function(entry) { %>
        <%= entry %>
    <% }) %>
    """)

    templateBase = _.template("""
    <section class="history">
        <ul class="history-tabs">
            <li>
                <a href="#" class="active">
                    <span class="icon icon-comment"></span>
                    <span class="tab-title">Comments</span>
                </a>
            </li>
            <li>
                <a href="#">
                    <span class="icon icon-issues"></span>
                    <span class="tab-title">Activity</span>
                </a>
            </li>
        </ul>
        <section class="history-comments">
            <div class="comments-list"></div>
            <div tg-check-permission="modify_<%- type %>" tg-toggle-comment class="add-comment">
                <textarea placeholder="Type a new comment here"
                    ng-model="<%- ngmodel %>.comment" tg-markitup="tg-markitup">
                </textarea>
                <% if (mode !== "edit") { %>
                <a href="" title="Comment" class="button button-green save-comment">Comment</a>
                <% } %>
            </div>
        </section>
        <section class="history-activity hidden">
            <div class="changes-list"></div>
        </section>
    </section>
    """)

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
            $ctrl.loadHistory()

        # Helpers

        getUserFullName = (userId) ->
            return $scope.usersById[userId]?.full_name_display

        getUserAvatar = (userId) ->
            return $scope.usersById[userId]?.photo

        countChanges = (comment) ->
            return _.keys(comment.values_diff).length

        formatChange = (change) ->
            if _.isArray(change)
                if change.length == 0
                    return "nil"
                return change.join(", ")

            if change == ""
                return "nil"

            return change

        # Render into string (operations without mutability)

        renderAttachmentEntry = (field, value) ->
            attachments = _.map value, (changes, type) ->
                if type == "new"
                    return _.map changes, (change) ->
                        return templateChangeDiff({name: "New attachment", diff: change.filename})
                else if type == "deleted"
                    return _.map changes, (change) ->
                        return templateChangeDiff({name: "Deleted attachment", diff: change.filename})
                else
                    return _.map changes, (change) ->
                        return templateChangeDiff({name: "Updated attachment", diff: change[0].filename})

            return _.flatten(attachments).join("\n")

        renderChangeEntry = (field, value) ->
            if field == "description"
                return templateChangeDiff({name: field, diff: value[1]})
            else if field == "points"
                return templateChangePoints({points: value})
            else if field == "attachments"
                return renderAttachmentEntry(field, value)
            else if field == "assigned_to"
                from = formatChange(value[0] or "Unassigned")
                to = formatChange(value[1] or "Unassigned")
                return templateChangeGeneric({name:field, from:from, to: to})
            else
                from = formatChange(value[0])
                to = formatChange(value[1])
                return templateChangeGeneric({name:field, from:from, to: to})

        renderChangeEntries = (change, join=true) ->
            entries = _.map(change.values_diff, (value, field) -> renderChangeEntry(field, value))
            if join
                return entries.join("\n")
            return entries

        renderChangesHelperText = (change) ->
            size = countChanges(change)
            if size == 1
                return "Made #{size} change" # TODO: i18n
            return "Made #{size} changes" # TODO: i18n

        renderComment = (comment) ->
            return templateActivity({
                avatar: getUserAvatar(comment.user.pk)
                userFullName: getUserFullName(comment.user.pk)
                creationDate: moment(comment.created_at).format("DD MMM YYYY HH:mm")
                comment: comment.comment_html
                changesText: renderChangesHelperText(comment)
                changes: renderChangeEntries(comment, false)
                mode: "comment"
            })

        renderChange = (change) ->
            return templateActivity({
                avatar: getUserAvatar(change.user.pk)
                userFullName: getUserFullName(change.user.pk)
                creationDate: moment(change.created_at).format("DD MMM YYYY HH:mm")
                comment: change.comment_html
                changes: renderChangeEntries(change, false)
                changesText: ""
                mode: "activity"
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

        # Watchers

        $scope.$watch("comments", renderComments)
        $scope.$watch("history",  renderActivity)

        $scope.$on("history:reload", -> $ctrl.loadHistory())

        # Events

        $el.on "click", ".add-comment a.button-green", (event) ->
            event.preventDefault()

            $el.find(".comment-list").addClass("activeanimation")
            onSuccess = ->
                $ctrl.loadHistory()

            onError = ->
                $confirm.notify("error")

            model = $scope.$eval($attrs.ngModel)
            $ctrl.repo.save(model).then(onSuccess, onError)

        $el.on "click", ".show-more", (event) ->
            event.preventDefault()

            target = angular.element(event.currentTarget)
            if target.parent().is(".changes-list")
                showAllActivity = not showAllActivity
                renderActivity()
            else
                showAllComments = not showAllComments
                renderComments()

        $el.on "click", ".changes-title", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.parent().find(".change-entry").toggleClass("active")

        $el.on "focus", ".add-comment textarea", (event) ->
            $(this).addClass('active')

        $el.on "click", ".history-tabs li a", (event) ->
            $el.find(".history-tabs li a").toggleClass("active")
            $el.find(".history section").toggleClass("hidden")

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


module.directive("tgHistory", ["$log", HistoryDirective])
