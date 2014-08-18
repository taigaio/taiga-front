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
# File: modules/base/tags.coffee
###

taiga = @.taiga

module = angular.module("taigaBase")

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
