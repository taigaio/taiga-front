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
            tags = _.map srcTags, (tag) ->
                color = $scope.project.tags_colors[tag]
                return {name: tag, color: color}

            html = template({tags: tags})
            $el.html(html)

        $scope.$watch $attrs.tgColorizeTags, (tags) ->
            render(tags) if tags?

    return {link: link}

module.directive("tgColorizeTags", ColorizeTagsDirective)

#############################################################################
## TagLine (possible should be moved as generic directive)
#############################################################################

TagLineDirective = ($rootscope, $log, $rs, $tgrepo, $confirm) ->
    # Main directive template (rendered by angular)
    template = """
    <div class="tags-container"></div>
    <a href="#" class="add-tag" title="Add tag">
        <span class="icon icon-plus"></span>
        <span class="add-tag-text">Add tag</span>
    </a>
    <input type="text" placeholder="Write tag..." class="tag-input hidden" />
    <a href="" title="Save" class="save icon icon-floppy"></a>
    """

    # Tags template (rendered manually using lodash)
    templateTags = _.template("""
    <% _.each(tags, function(tag) { %>
        <span class="tag" style="border-left: 5px solid <%- tag.color %>;">
            <span class="tag-name"><%- tag.name %></span>
            <% if (editable) { %>
            <a href="" title="delete tag" class="icon icon-delete"></a>
            <% } %>
        </span>
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
        editable = false

        $el.addClass("tags-block")

        addValue = (value) ->
            value = trim(value)
            return if value.length <= 0

            tags = _.clone($model.$modelValue, false)
            tags = [] if not tags?
            tags.push(value)

            $scope.$apply ->
                $model.$setViewValue(normalizeTags(tags))
                autosaveModel = $scope.$eval($attrs.autosaveModel)
                if autosaveModel
                    promise = $tgrepo.save(autosaveModel)
                    promise.then ->
                        $rootscope.$broadcast("history:reload")
                    promise.then null, ->
                        $confirm.notify("error")

        saveInputTag = () ->
            input = $el.find('input')

            addValue(input.val())
            input.val("")
            input.autocomplete("close")
            $el.find('.save').hide()

        $scope.$watch $attrs.ngModel, (val) ->
            tags_colors = if $scope.project?.tags_colors? then $scope.project.tags_colors else []
            renderTags($el, val, editable, tags_colors)

            if val? and val.length > 0
                $el.find("span.add-tag-text").hide()
            else
                $el.find("span.add-tag-text").show()


        bindOnce $scope, "project", (project) ->
            # If not editable, no tags preloading is needed.
            editable = if $attrs.editable == "true" then true else false
            editable = editable and project.my_permissions.indexOf($attrs.requiredPerm) != -1

            if not editable
                $el.find("input").remove()
                return

            positioningFunction = (position, elements) ->
                menu = elements.element.element
                menu.css("width", elements.target.width)
                menu.css("top", position.top)
                menu.css("left", position.left)

            $rs.projects.tags(project.id).then (data) ->
                $el.find("input").autocomplete({
                    source: data
                    position: {
                        my: "left top",
                        using: positioningFunction
                    }
                    select: (event, ui) ->
                        addValue(ui.item.value)
                        ui.item.value = ""
                })

        $el.on "keypress", "input", (event) ->
            return if event.keyCode != 13
            event.preventDefault()

        $el.on "keyup", "input", (event) ->
            target = angular.element(event.currentTarget)

            if event.keyCode == 13
                saveInputTag()
            else if target.val().length
                $el.find('.save').show()
            else
                $el.find('.save').hide()

        $el.on "click", ".save", saveInputTag

        $el.on "click", ".add-tag", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            target.hide()
            target.siblings('input').removeClass('hidden')

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
                autosaveModel = $scope.$eval($attrs.autosaveModel)
                if autosaveModel
                    promise = $tgrepo.save(autosaveModel)
                    promise.then ->
                        $rootscope.$broadcast("history:reload")
                    promise.then null, ->
                        $confirm.notify("error")

    return {
        link:link,
        require:"ngModel"
        template: template
    }

module.directive("tgTagLine", ["$rootScope", "$log", "$tgResources", "$tgRepo", "$tgConfirm", TagLineDirective])
