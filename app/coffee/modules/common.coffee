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
# File: modules/common.coffee
###

taiga = @.taiga

trim = @.taiga.trim
typeIsArray = @.taiga.typeIsArray

module = angular.module("taigaCommon", [])


#############################################################################
## Change (comment and history mode) directive
#############################################################################

ChangesDirective = ->
    containerTemplate = _.template("""
    <div>
        <% if (showMoreEnabled){ %>
            <a href="" title="Show more" class="show-more show-more-comments">
            + Show previous comments (<%- howManyMore %> more)
            </a>
        <% } %>
    </div>
    """) # TODO: i18n
    commentBaseTemplate = _.template("""
    <div class="entry comment-single <% if(hidden){ %>hidden<% }%>">
        <div class="comment-user activity-comment">
            <a class="avatar" href="" title="<%- userFullName %>">
                <img src="<%- avatar %>" alt="<%- userFullName %>">
            </a>
        </div>
        <div class="comment-content">
            <a class="username" href="" title="<%- userFullName %>">
                <%- userFullName %>
            </a>
            <% if(hasChanges){ %>
            <div class="us-activity">
                <a class="activity-title" href="" title="Show activity">
                  <span>
                      <%- changesText %>
                  </span>
                  <span class="icon icon-arrow-up">
                  </span>
                </a>
            </div>
            <% } %>

            <div class="comment wysiwyg">
                <%= comment %>
            </div>
            <div class="date">
                <%- creationDate %>
            </div>
        </div>
    </div>
    """)
    changeBaseTemplate = _.template("""
    <div class="entry activity-single <% if(hidden){ %>hidden<% }%>">
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
            <div class="comment wysiwyg">
                <%= comment %>
            </div>
        </div>
    </div>
    """)
    standardChangeFromToTemplate = _.template("""
    <div class="activity-inner">
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
    """) # TODO: i18n
    descriptionChangeTemplate = _.template("""
    <div class="activity-inner">
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
    pointsChangeTemplate = _.template("""
    <% _.each(points, function(point, name) { %>
    <div class="activity-inner">
        <div class="activity-changed">
            <span><%- name %> points</span>
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
    """) # TODO: i18n
    attachmentTemplate = _.template("""
    <div class="activity-inner">
        <div class="activity-changed">
            <span><%- name %></span>
        </div>
        <div class="activity-fromto">
            <%- description %>
        </div>
    </div>
    """)
    link = ($scope, $el, $attrs, $model) ->
        $.uncollapsedEntries = null
        countChanges = (comment) ->
            return _.keys(comment.values_diff).length

        buildChangesText = (comment) ->
            size = countChanges(comment)
            if size == 1
                return "Made #{size} change" # TODO: i18n
            return "Made #{size} changes" # TODO: i18n

        renderEntries = (change, parentDomNode) ->
            _.each change.values_diff, (modification, name) ->
                if name == "description"
                    parentDomNode.append(descriptionChangeTemplate({
                        name: name
                        diff: modification[1]
                    }))
                else if name == "points"
                    parentDomNode.append(pointsChangeTemplate({
                        points: modification
                    }))
                else if name == "attachments"
                    _.each modification, (attachmentChanges, attachmentType) ->
                        if attachmentType == "new"
                            _.each attachmentChanges, (attachmentChange) ->
                                parentDomNode.append(attachmentTemplate({
                                    name: "New attachment" # TODO: i18n
                                    description: attachmentChange.filename
                                }))
                        else if attachmentType == "deleted" # TODO: i18n
                            _.each attachmentChanges, (attachmentChange) ->
                                parentDomNode.append(attachmentTemplate({
                                    name: "Deleted attachment"
                                    description: attachmentChange.filename
                                }))
                        else
                            name = "Updated attachment"
                            _.each attachmentChanges, (attachmentChange) ->
                                parentDomNode.append(attachmentTemplate({
                                    name: "Updated attachment" # TODO: i18n
                                    description: attachmentChange[0].filename
                                }))
                else if name == "assigned_to"
                    parentDomNode.append(standardChangeFromToTemplate({
                        name: name
                        from: prettyPrintModification(modification[0]) ? "Unassigned" # TODO: i18n
                        to: prettyPrintModification(modification[1]) ? "Unassigned" # TODO: i18n
                    }))
                else
                    parentDomNode.append(standardChangeFromToTemplate({
                        name: name
                        from: prettyPrintModification(modification[0])
                        to: prettyPrintModification(modification[1])
                    }))

        renderComment = (comment, containerDomNode, hidden) ->
            html = commentBaseTemplate({
                avatar: getUserAvatar(comment.user.pk)
                userFullName: getUserFullName(comment.user.pk)
                creationDate: moment(comment.created_at).format("DD MMM YYYY HH:mm")
                comment: comment.comment_html
                changesText: buildChangesText(comment)
                hasChanges: countChanges(comment) > 0
                hidden: hidden
            })
            entryDomNode = $(html)
            activityContentDom = entryDomNode.find(".comment-content .us-activity")
            renderEntries(comment, activityContentDom)
            containerDomNode.append(entryDomNode)

        renderChange = (change, containerDomNode, hidden) ->
            html = changeBaseTemplate({
                avatar: getUserAvatar(change.user.pk)
                userFullName: getUserFullName(change.user.pk)
                creationDate: moment(change.created_at).format("DD MMM YYYY HH:mm")
                comment: change.comment_html
                hidden: hidden
            })
            entryDomNode = $(html)
            activityContentDom = entryDomNode.find(".activity-content")
            renderEntries(change, activityContentDom)
            containerDomNode.append(entryDomNode)

        getUserFullName = (userId) ->
            return $scope.usersById[userId]?.full_name_display

        getUserAvatar = (userId) ->
            return $scope.usersById[userId]?.photo

        prettyPrintModification = (value) ->
            if typeIsArray(value)
                if value.length == 0
                    #TODO i18n
                    return "None" # TODO: i18n
                return value.join(", ")

            if value == ""
                #TODO i18n
                return "None" # TODO: i18n

            return value

        $scope.$watch $attrs.ngModel, (changes) ->
            if not changes?
                return

            showMoreEnabled = $.uncollapsedEntries == null and changes.length > 2
            howManyMore = changes.length - 2
            html = containerTemplate({
                showMoreEnabled: showMoreEnabled
                howManyMore: howManyMore
            })

            containerDomNode = $(html)
            _.each changes, (change, index) ->
                hidden = showMoreEnabled and index < howManyMore
                if $attrs.mode == "comment"
                    renderComment(change, containerDomNode, hidden)
                else
                    renderChange(change, containerDomNode, hidden)

            $el.html(containerDomNode)

        $el.on "click", ".activity-title", (event) ->
            event.preventDefault()
            $el.find(".activity-inner").toggleClass("active")

        $el.on "click", ".show-more", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.hide()
            $el.find(".entry.hidden").removeClass("hidden")
            $.uncollapsedEntries = true

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgChanges", ChangesDirective)


#############################################################################
## Permission directive, hide elements when necessary
#############################################################################

CheckPermissionDirective = ->
    showElementIfPermission = (element, permission, project) ->
        element.show() if project.my_permissions.indexOf(permission) > -1

    link = ($scope, $el, $attrs) ->
        $el.hide()
        permission = $attrs.permission

        #Sometimes this directive from a self included html template
        if $scope.project?
            showElementIfPermission($el, permission, $scope.project)

        $scope.$on "project:loaded", (ctx, project) ->
            showElementIfPermission($el, permission, project)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgCheckPermission", CheckPermissionDirective)

#############################################################################
## Animation frame service, apply css changes in the next render frame
#############################################################################
AnimationFrame = () ->
    animationFrame =
        window.requestAnimationFrame       ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame

    performAnimation = (time) =>
        fn = tail.shift()
        fn()

        if (tail.length)
            animationFrame(performAnimation)

    tail = []

    add = () ->
        for fn in arguments
            tail.push(fn)

            if tail.length == 1
                animationFrame(performAnimation)

    return {add: add}

module.factory("animationFrame", AnimationFrame)

#############################################################################
## Open/close comment
#############################################################################

ToggleCommentDirective = () ->
    link = ($scope, $el, $attrs) ->
        $el.find("textarea").on "focus", () ->
            $el.addClass("active")

    return {link:link}

module.directive("tgToggleComment", ToggleCommentDirective)

#############################################################################
## Set the page title
#############################################################################

AppTitle = () ->
    set = (text) ->
        $("title").text(text)

    return {set: set}

module.factory("$appTitle", AppTitle)

#############################################################################
## Get the appropiate section url for a project
## according to his enabled features and user permisions
#############################################################################

ProjectUrl = ($navurls) ->
    get = (project) ->
        ctx = {project: project.slug}

        if project.is_backlog_activated and project.my_permissions.indexOf("view_us") > -1
            return $navurls.resolve("project-backlog", ctx)
        if project.is_kanban_activated and project.my_permissions.indexOf("view_us") > -1
            return $navurls.resolve("project-kanban", ctx)
        if project.is_wiki_activated and project.my_permissions.indexOf("view_wiki_pages") > -1
            return $navurls.resolve("project-wiki", ctx)
        if project.is_issues_activated and project.my_permissions.indexOf("view_issues") > -1
            return $navurls.resolve("project-issues", ctx)

        return $navurls.resolve("project", ctx)

    return {get: get}

module.factory("$projectUrl", ["$tgNavUrls", ProjectUrl])


#############################################################################
## Limite line size in a text area
#############################################################################

LimitLineLengthDirective = () ->
    link = ($scope, $el, $attrs) ->
        maxColsPerLine = parseInt($el.attr("cols"))
        $el.on "keyup", (event) ->
            code = event.keyCode
            lines = $el.val().split("\n")

            _.each lines, (line, index) ->
                lines[index] = line.substring(0, maxColsPerLine - 2)

            $el.val(lines.join("\n"))

    return {link:link}

module.directive("tgLimitLineLength", LimitLineLengthDirective)
