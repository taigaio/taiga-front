###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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


ColorizeTagsBacklogDirective = ($emojis) ->
    template = _.template("""
        <% _.each(tags, function(tag) { %>
            <% if (tag[1] !== null) { %>
            <div class="tag" style="background: <%- tag[1] %>">
                <%= emojify(tag[0]) %>
            </div>
            <% } %>
        <% }) %>
        <% _.each(tags, function(tag) { %>
            <% if (tag[1] === null) { %>
            <div class="tag">
                <%= emojify(tag[0]) %>
            </div>
            <% } %>
        <% }) %>
    """)

    link = ($scope, $el, $attrs, $ctrl) ->
        render = (tags) ->
            html = template({tags: tags, emojify: (text) -> $emojis.replaceEmojiNameByHtmlImgs(_.escape(text))})
            $el.html(html)

        $scope.$watch $attrs.tgColorizeBacklogTags, (tags) ->
            render(tags) if tags?

        $scope.$on "$destroy", ->
            $el.off()

    return {link: link}

module.directive("tgColorizeBacklogTags", ["$tgEmojis", ColorizeTagsBacklogDirective])


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
