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
textToColor = @.taiga.textToColor

module = angular.module("taigaCommon", [])


#############################################################################
## TagLine (possible should be moved as generic directive)
#############################################################################

TagLineDirective = ($log) ->
    # Main directive template (rendered by angular)
    template = """
    <div class="tags-container"></div>
    <input type="text" placeholder="Write tag..." class="hidden"/>
    """

    # Tags template (rendered manually using lodash)
    templateTags = _.template("""
    <% _.each(tags, function(tag) { %>
        <div class="tag" style="background: <%- tag.color %>;">
            <span class="tag-name"><%- tag.name %></span>
            <% if (editable) { %>
            <a href="" title="delete tag" class="icon icon-delete"></a>
            <% } %>
        </div>
    <% }); %>""")

    renderTags = ($el, tags, editable) ->
        ctx = {
            tags: _.map(tags, (t) -> {name: t, color: textToColor(t)})
            editable: editable
        }
        html = templateTags(ctx)
        $el.find("div.tags-container").html(html)

    normalizeTags = (tags) ->
        tags = _.map(tags, trim)
        tags = _.map(tags, (x) -> x.toLowerCase())
        return _.uniq(tags)

    link = ($scope, $el, $attrs, $model) ->
        editable = if $attrs.editable == "true" then true else false

        $scope.$watch $attrs.ngModel, (val) ->
            return if not val
            renderTags($el, val, editable)

        $el.find("input").remove() if not editable

        $el.on "keyup", "input", (event) ->
            return if event.keyCode != 13
            target = angular.element(event.currentTarget)
            value = trim(target.val())

            if value.length <= 0
                return

            tags = _.clone($model.$modelValue, false)
            tags = [] if not tags?
            tags.push(value)

            target.val("")

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            value = trim(target.siblings(".tag-name").text())

            if value.length <= 0
                return

            tags = _.clone($model.$modelValue, false)
            tags = _.pull(tags, value)

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))

    return {
        link:link,
        require:"ngModel"
        template: template
    }

module.directive("tgTagLine", ["$log", TagLineDirective])

#############################################################################
## Change (comment and history mode) directive
#############################################################################

ChangeDirective = ->
    # TODO: i18n
    commentBaseTemplate = _.template("""
    <div class="comment-user activity-comment">
        <a class="avatar" href="" title="<%- userFullName %>">
            <img src="<%- avatar %>" alt="<%- userFullName %>">
        </a>
    </div>
    <div class="comment-content">
        <a class="username" href="TODO" title="<%- userFullName %>">
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

        <p class="comment">
            <%- comment %>
        </p>
        <p class="date">
            <%- creationDate %>
        </p>
    </div>
    """)
    changeBaseTemplate = _.template("""
    <div class="activity-user">
        <a class="avatar" href="" title="<%- userFullName %>">
            <img src="<%- avatar %>" alt="<%- userFullName %>">
        </a>
    </div>
    <div class="activity-content">
        <div class="activity-username">
            <a class="username" href="TODO" title="<%- userFullName %>">
                <%- userFullName %>
            </a>
            <span class="date">
                <%- creationDate %>
            </span>
        </div>
        <p class="comment">
            <%- comment %>
        </p>
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
    """)
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
    """)
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
        countChanges = (comment) ->
            return _.keys(comment.values_diff).length

        buildChangesText = (comment) ->
            size = countChanges(comment)
            # TODO: i18n
            if size == 1
                return "Made #{size} change"
            return "Made #{size} changes"

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
                                    name: "New attachment"
                                    description: attachmentChange.filename
                                }))
                        else if attachmentType == "deleted"
                            _.each attachmentChanges, (attachmentChange) ->
                                parentDomNode.append(attachmentTemplate({
                                    name: "Deleted attachment"
                                    description: attachmentChange.filename
                                }))
                        else
                            name = "Updated attachment"
                            _.each attachmentChanges, (attachmentChange) ->
                                parentDomNode.append(attachmentTemplate({
                                    name: "Updated attachment"
                                    description: attachmentChange[0].filename
                                }))

                else
                    parentDomNode.append(standardChangeFromToTemplate({
                        name: name
                        from: prettyPrintModification(modification[0])
                        to: prettyPrintModification(modification[1])
                    }))

        renderComment = (comment) ->
            html = commentBaseTemplate({
                avatar: getUserAvatar(comment.user.pk)
                userFullName: getUserFullName(comment.user.pk)
                creationDate: moment(comment.created_at).format("YYYY/MM/DD HH:mm")
                comment: comment.comment
                changesText: buildChangesText(comment)
                hasChanges: countChanges(comment) > 0
            })

            $el.html(html)
            activityContentDom = $el.find(".comment-content .us-activity")
            renderEntries(comment, activityContentDom)

        renderChange = (change) ->
            html = changeBaseTemplate({
                avatar: getUserAvatar(change.user.pk)
                userFullName: getUserFullName(change.user.pk)
                creationDate: moment(change.created_at).format("YYYY/MM/DD HH:mm")
                comment: change.comment
            })

            $el.html(html)
            activityContentDom = $el.find(".activity-content")
            renderEntries(change, activityContentDom)

        getUserFullName = (userId) ->
            return $scope.usersById[userId]?.full_name_display

        getUserAvatar = (userId) ->
            return $scope.usersById[userId]?.photo

        prettyPrintModification = (value) ->
            if typeIsArray(value)
                if value.length == 0
                  #TODO i18n
                  return "None"
                else
                  return value.join(", ")

            if value == ""
                return "None"

            return value

        $scope.$watch $attrs.ngModel, (change) ->
            if not change?
                return

            if $attrs.mode == "comment"
                renderComment(change)
            else
                renderChange(change)

        $el.on "click", ".activity-title", (event) ->
            event.preventDefault()
            $el.find(".activity-inner").toggleClass("active")

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link, require:"ngModel"}

module.directive("tgChange", ChangeDirective)


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
