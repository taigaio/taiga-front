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
# File: modules/common/tags.coffee
###

taiga = @.taiga
trim = @.taiga.trim

module = angular.module("taigaCommon")

# Directive that parses/format tags inputfield.

TagsDirective = ->
    formatter = (v) ->
        if _.isArray(v)
            return v.join(", ")
        return ""

    parser = (v) ->
        return [] if not v
        result = _(v.split(",")).map((x) -> _.str.trim(x))

        return result.value()

    link = ($scope, $el, $attrs, $ctrl) ->
        $ctrl.$formatters.push(formatter)
        $ctrl.$parsers.push(parser)

    return {
        require: "ngModel"
        link: link
    }

module.directive("tgTags", TagsDirective)


ColorizeTagsDirective = ->
    templates = {
        backlog: _.template("""
            <% _.each(tags, function(tag) { %>
                <span class="tag" style="border-left: 5px solid <%- tag.color %>"><%- tag.name %></span>
            <% }) %>
        """)
        kanban: _.template("""
            <% _.each(tags, function(tag) { %>
                <a class="kanban-tag" href="" style="background: <%- tag.color %>" title="<%- tag.name %>" />
            <% }) %>
        """)
        taskboard: _.template("""
            <% _.each(tags, function(tag) { %>
                <a class="taskboard-tag" href="" style="background: <%- tag.color %>" title="<%- tag.name %>" />
            <% }) %>
        """)
    }
    link = ($scope, $el, $attrs, $ctrl) ->
        render = (srcTags) ->
            template = templates[$attrs.tgColorizeTagsType]
            tags = []
            for tag in srcTags
                color = $scope.project.tags_colors[tag]
                tags.push({name: tag, color: color})
            $el.html template({tags: tags})

        $scope.$watch $attrs.tgColorizeTags, ->
            tags = $scope.$eval($attrs.tgColorizeTags)
            if tags?
                render(tags)

        tags = $scope.$eval($attrs.tgColorizeTags)
        if tags?
            render(tags)

    return {link: link}

module.directive("tgColorizeTags", ColorizeTagsDirective)

#############################################################################
## TagLine (possible should be moved as generic directive)
#############################################################################

TagLineDirective = ($log, $rs) ->
    # Main directive template (rendered by angular)
    template = """
    <div class="tags-container"></div>
    <input type="text" placeholder="Write tag..." class="tag-input" />
    """

    # Tags template (rendered manually using lodash)
    templateTags = _.template("""
    <% _.each(tags, function(tag) { %>
        <div class="tag" style="border-left: 5px solid <%- tag.color %>;">
            <span class="tag-name"><%- tag.name %></span>
            <% if (editable) { %>
            <a href="" title="delete tag" class="icon icon-delete"></a>
            <% } %>
        </div>
    <% }); %>""")

    renderTags = ($el, tags, editable, tagsColors) ->
        ctx = {
            tags: _.map(tags, (t) -> {name: t, color: tagsColors[t]})
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
        $el.addClass('tags-block')

        addValue = (value) ->
            value = trim(value)
            return if value.length <= 0

            tags = _.clone($model.$modelValue, false)
            tags = [] if not tags?
            tags.push(value)

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))


        $scope.$watch $attrs.ngModel, (val) ->
            return if not val
            renderTags($el, val, editable, $scope.project.tags_colors)

        $scope.$watch "projectId", (val) ->
            return if not val?
            positioningFunction = (position, elements) ->
                menu = elements.element.element
                menu.css 'width', elements.target.width
                menu.css 'top', position.top
                menu.css 'left', position.left

            promise = $rs.projects.tags($scope.projectId)
            promise.then (data) ->
                if editable
                    $el.find("input").autocomplete({
                        source: data,
                        position:
                            my: "left top",
                            using: positioningFunction
                        select: (event, ui) ->
                            addValue(ui.item.value)
                            ui.item.value = ""
                    })

        $el.find("input").remove() if not editable

        $el.on "keypress", "input", (event) ->
            return if event.keyCode != 13
            event.preventDefault()

        $el.on "keyup", "input", (event) ->
            return if event.keyCode != 13
            event.preventDefault()

            target = angular.element(event.currentTarget)
            addValue(target.val())
            target.val("")
            $el.find("input").autocomplete("close")


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

module.directive("tgTagLine", ["$log", "$tgResources", TagLineDirective])
