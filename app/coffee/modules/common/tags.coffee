###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
bindOnce = @.taiga.bindOnce


module = angular.module("taigaCommon")

# Directive that parses/format tags inputfield.

TagsDirective = ->
    formatter = (v) ->
        if _.isArray(v)
            return v.join(", ")
        return ""

    parser = (v) ->
        return [] if not v
        result = _(v.split(",")).map((x) -> _.trim(x))

        return result.value()

    link = ($scope, $el, $attrs, $ctrl) ->
        $ctrl.$formatters.push(formatter)
        $ctrl.$parsers.push(parser)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        require: "ngModel"
        link: link
    }

module.directive("tgTags", TagsDirective)


ColorizeTagsDirective = ->
    templates = {
        backlog: _.template("""
        <% _.each(tags, function(tag) { %>
            <span class="tag"
                <% if (tag[1] === null || tag[1] == undefined) { %>
                    style="border-left: 5px solid <%- tag[1] %>"
                <% } %>
                title="<%- tag[0] %>"><%- tag[0] %></span>
        <% }) %>
        """)
        kanban: _.template("""
        <% _.each(tags, function(tag) { %>
            <a class="kanban-tag"
                href=""
                <% if (tag[1] === null || tag[1] == undefined) { %>
                    style="border-color: <%- tag[1] %>"
                <% } %>
                title="<%- tag[0] %>" />
        <% }) %>
        """)
        taskboard: _.template("""
        <% _.each(tags, function(tag) { %>
            <a class="taskboard-tag"
                href=""
                <% if (tag[1] === null || tag[1] == undefined) { %>
                    style="border-color: <%- tag[1] %>"
                <% } %>
                title="<%- tag[0] %>" />
        <% }) %>
        """)
    }

    link = ($scope, $el, $attrs, $ctrl) ->
        render = (tags) ->
            template = templates[$attrs.tgColorizeTagsType]

            html = template({tags: tags})
            $el.html(html)

        $scope.$watch $attrs.tgColorizeTags, (tags) ->
            render(tags) if tags?

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgColorizeTags", ColorizeTagsDirective)


#############################################################################
## TagLine  Directive (for Lightboxes)
#############################################################################

LbTagLineDirective = ($rs, $template, $compile) ->
    ENTER_KEY = 13
    COMMA_KEY = 188

    templateTags = $template.get("common/tag/lb-tag-line-tags.html", true)

    autocomplete = null

    link = ($scope, $el, $attrs, $model) ->
        withoutColors = _.has($attrs, "withoutColors")

        ## Render
        renderTags = (tags, tagsColors = []) ->
            color = if not withoutColors then tagsColors[t] else null

            ctx = {
                tags: _.map(tags, (t) -> {
                    name: t,
                    style: if color then "border-left: 5px solid #{color}" else ""
                })
            }

            html = $compile(templateTags(ctx))($scope)
            $el.find(".tags-container").html(html)

        showSaveButton = ->
            $el.find(".save").removeClass("hidden")

        hideSaveButton = ->
            $el.find(".save").addClass("hidden")

        resetInput = ->
            $el.find("input").val("")
            autocomplete.close()

        ## Aux methods
        addValue = (value) ->
            value = trim(value.toLowerCase())
            return if value.length == 0

            tags = _.clone($model.$modelValue, false)
            tags = [] if not tags?
            tags.push(value) if value not in tags

            $scope.$apply ->
                $model.$setViewValue(tags)

            hideSaveButton()

        deleteValue = (value) ->
            value = trim(value.toLowerCase())
            return if value.length == 0

            tags = _.clone($model.$modelValue, false)
            tags = _.pull(tags, value)

            $scope.$apply ->
                $model.$setViewValue(tags)

        saveInputTag = () ->
            value = $el.find("input").val()

            addValue(value)
            resetInput()

        ## Events
        $el.on "keypress", "input", (event) ->
            target = angular.element(event.currentTarget)

            if event.keyCode == ENTER_KEY
                event.preventDefault()
                saveInputTag()
            else if String.fromCharCode(event.keyCode) == ','
                event.preventDefault()
                saveInputTag()
            else
                if target.val().length
                    showSaveButton()
                else
                    hideSaveButton()

        $el.on "click", ".save", (event) ->
            event.preventDefault()
            saveInputTag()

        $el.on "click", ".remove-tag", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            value = target.siblings(".tag-name").text()
            deleteValue(value)

        bindOnce $scope, "project", (project) ->
            input = $el.find("input")

            autocomplete = new Awesomplete(input[0], {
                list: _.keys(project.tags_colors)
            })

            input.on "awesomplete-selectcomplete", () ->
                addValue(input.val())
                input.val("")

        $scope.$watch $attrs.ngModel, (tags) ->
            tagsColors = $scope.project?.tags_colors or []
            renderTags(tags, tagsColors)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        require:"ngModel"
        templateUrl: "common/tag/lb-tag-line.html"
    }

module.directive("tgLbTagLine", ["$tgResources", "$tgTemplate", "$compile", LbTagLineDirective])
