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
            <span class="tag" style="border-left: 5px solid <%- tag.color %>"><%- tag.name %></span>
        <% }) %>
        """)
        kanban: _.template("""
        <% _.each(tags, function(tag) { %>
            <a class="kanban-tag" href="" style="border-color: <%- tag.color %>" title="<%- tag.name %>" />
        <% }) %>
        """)
        taskboard: _.template("""
        <% _.each(tags, function(tag) { %>
            <a class="taskboard-tag" href="" style="border-color: <%- tag.color %>" title="<%- tag.name %>" />
        <% }) %>
        """)
    }

    link = ($scope, $el, $attrs, $ctrl) ->
        render = (srcTags) ->
            template = templates[$attrs.tgColorizeTagsType]
            srcTags.sort()
            tags = _.map srcTags, (tag) ->
                color = $scope.project.tags_colors[tag]
                return {name: tag, color: color}

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

LbTagLineDirective = ($rs) ->
    ENTER_KEY = 13

    template = """
    <div class="tags-container"></div>
    <input type="text" placeholder="I'm it! Tag me..." class="tag-input" />
    <a href="" title="Save" class="save icon icon-floppy hidden"></a>
    """ # TODO: i18n

    # Tags template (rendered manually using lodash)
    templateTags = _.template("""
    <% _.each(tags, function(tag) { %>
        <span class="tag"  <% if (tag.color) { %> style="border-left: 5px solid <%- tag.color %>;"<% } %>>
            <span class="tag-name"><%- tag.name %></span>
            <a href="" title="delete tag" class="icon icon-delete"></a>
        </span>
    <% }); %>
    """) # TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        ## Render
        renderTags = (tags, tagsColors) ->
            ctx = {
                tags: _.map(tags, (t) -> {name: t, color: tagsColors[t]})
            }
            html = templateTags(ctx)
            $el.find("div.tags-container").html(html)

        showSaveButton = -> $el.find(".save").removeClass("hidden")
        hideSaveButton = -> $el.find(".save").addClass("hidden")

        resetInput = ->
            $el.find("input").val("")
            $el.find("input").autocomplete("close")

        ## Aux methods
        addValue = (value) ->
            value = trim(value.toLowerCase())
            return if value.length == 0

            tags = _.clone($model.$modelValue, false)
            tags = [] if not tags?
            tags.push(value) if value not in tags

            $scope.$apply ->
                $model.$setViewValue(tags)

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
            hideSaveButton()

        ## Events
        $el.on "keypress", "input", (event) ->
            return if event.keyCode != ENTER_KEY
            event.preventDefault()

        $el.on "keyup", "input", (event) ->
            target = angular.element(event.currentTarget)

            if event.keyCode == ENTER_KEY
                saveInputTag()
            else
                if target.val().length
                    showSaveButton()
                else
                    hideSaveButton()

        $el.on "click", ".save", (event) ->
            event.preventDefault()
            saveInputTag()

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            value = target.siblings(".tag-name").text()
            deleteValue(value)

        bindOnce $scope, "project", (project) ->
            positioningFunction = (position, elements) ->
                menu = elements.element.element
                menu.css("width", elements.target.width)
                menu.css("top", position.top)
                menu.css("left", position.left)

            $el.find("input").autocomplete({
                source: _.keys(project.tags_colors)
                position: {
                    my: "left top",
                    using: positioningFunction
                }
                select: (event, ui) ->
                    addValue(ui.item.value)
                    ui.item.value = ""
            })

        $scope.$watch $attrs.ngModel, (tags) ->
            tagsColors = $scope.project?.tags_colors or []
            renderTags(tags, tagsColors)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        require:"ngModel"
        template: template
    }

module.directive("tgLbTagLine", ["$tgResources", LbTagLineDirective])


#############################################################################
## TagLine  Directive (for detail pages)
#############################################################################

TagLineDirective = ($rootScope, $repo, $rs, $confirm) ->
    ENTER_KEY = 13
    ESC_KEY = 27

    template = """
    <div class="tags-container"></div>
    <a href="#" class="add-tag hidden" title="Add tag">
        <span class="icon icon-plus"></span>
        <span class="add-tag-text">Add tag</span>
    </a>
    <input type="text" placeholder="I'm it! Tag me..." class="tag-input hidden" />
    <a href="" title="Save" class="save icon icon-floppy hidden"></a>
    """ # TODO: i18n

    # Tags template (rendered manually using lodash)
    templateTags = _.template("""
    <% _.each(tags, function(tag) { %>
        <span class="tag" style="border-left: 5px solid <%- tag.color %>;">
            <span class="tag-name"><%- tag.name %></span>
            <% if (isEditable) { %>
            <a href="" title="delete tag" class="icon icon-delete"></a>
            <% } %>
        </span>
    <% }); %>
    """) # TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf($attrs.requiredPerm) != -1

        ## Render
        renderTags = (tags, tagsColors) ->
            ctx = {
                tags: _.map(tags, (t) -> {name: t, color: tagsColors[t]})
                isEditable: isEditable()
            }
            html = templateTags(ctx)
            $el.find("div.tags-container").html(html)

        renderInReadModeOnly = ->
            $el.find(".add-tag").remove()
            $el.find("input").remove()
            $el.find(".save").remove()

        showAddTagButton = -> $el.find(".add-tag").removeClass("hidden")
        hideAddTagButton = -> $el.find(".add-tag").addClass("hidden")

        showAddTagButtonText = -> $el.find(".add-tag-text").removeClass("hidden")
        hideAddTagButtonText = -> $el.find(".add-tag-text").addClass("hidden")

        showSaveButton = -> $el.find(".save").removeClass("hidden")
        hideSaveButton = -> $el.find(".save").addClass("hidden")

        showInput = -> $el.find("input").removeClass("hidden").focus()
        hideInput = -> $el.find("input").addClass("hidden").blur()
        resetInput = ->
            $el.find("input").val("")
            $el.find("input").autocomplete("close")

        ## Aux methods
        addValue = (value) ->
            value = trim(value.toLowerCase())
            return if value.length == 0

            tags = _.clone($model.$modelValue.tags, false)
            tags = [] if not tags?
            tags.push(value) if value not in tags

            model = $model.$modelValue.clone()
            model.tags = tags
            $model.$setViewValue(model)

            onSuccess = ->
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                model.revert()
                $model.$setViewValue(model)
            $repo.save(model).then(onSuccess, onError)

        deleteValue = (value) ->
            value = trim(value.toLowerCase())
            return if value.length == 0

            tags = _.clone($model.$modelValue.tags, false)
            tags = _.pull(tags, value)

            model = $model.$modelValue.clone()
            model.tags = tags
            $model.$setViewValue(model)

            onSuccess = ->
                $rootScope.$broadcast("history:reload")
            onError = ->
                $confirm.notify("error")
                model.revert()
                $model.$setViewValue(model)
            $repo.save(model).then(onSuccess, onError)

        saveInputTag = () ->
            value = $el.find("input").val()

            addValue(value)
            resetInput()
            hideSaveButton()

        ## Events
        $el.on "keypress", "input", (event) ->
            return if event.keyCode not in [ENTER_KEY, ESC_KEY]
            event.preventDefault()

        $el.on "keyup", "input", (event) ->
            target = angular.element(event.currentTarget)

            if event.keyCode == ENTER_KEY
                saveInputTag()
            else if event.keyCode == ESC_KEY
                resetInput()
                hideInput()
                hideSaveButton()
                showAddTagButton()
            else
                if target.val().length
                    showSaveButton()
                else
                    hideSaveButton()

        $el.on "click", ".save", (event) ->
            event.preventDefault()
            saveInputTag()

        $el.on "click", ".add-tag", (event) ->
            event.preventDefault()
            hideAddTagButton()
            showInput()

        $el.on "click", ".icon-delete", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)

            value = target.siblings(".tag-name").text()
            deleteValue(value)

        bindOnce $scope, "project", (project) ->
            if not isEditable()
                renderInReadModeOnly()
                return

            showAddTagButton()

            positioningFunction = (position, elements) ->
                menu = elements.element.element
                menu.css("width", elements.target.width)
                menu.css("top", position.top)
                menu.css("left", position.left)

            $el.find("input").autocomplete({
                source: _.keys(project.tags_colors)
                position: {
                    my: "left top",
                    using: positioningFunction
                }
                select: (event, ui) ->
                    addValue(ui.item.value)
                    ui.item.value = ""
            })

        $scope.$watch $attrs.ngModel, (model) ->
            return if not model

            if model.tags?.length
                hideAddTagButtonText()
            else
                showAddTagButtonText()

            tagsColors = $scope.project?.tags_colors or []
            renderTags(model.tags, tagsColors)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link:link,
        require:"ngModel"
        template: template
    }

module.directive("tgTagLine", ["$rootScope", "$tgRepo", "$tgResources", "$tgConfirm", TagLineDirective])
