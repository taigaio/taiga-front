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
# File: modules/wiki/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
unslugify = @.taiga.unslugify
debounce = @.taiga.debounce

module = angular.module("taigaWiki")

#############################################################################
## Wiki Detail Controller
#############################################################################

class WikiDetailController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgModel",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$filter",
        "$log",
        "$appTitle",
        "$tgNavUrls",
        "$tgAnalytics",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @model, @confirm, @rs, @params, @q, @location,
                  @filter, @log, @appTitle, @navUrls, @analytics, tgLoader) ->
        @scope.projectSlug = @params.pslug
        @scope.wikiSlug = @params.slug
        @scope.sectionName = "Wiki"

        promise = @.loadInitialData()

        # On Success
        promise.then () =>
            @appTitle.set("Wiki - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadWiki: ->
        if @scope.wikiId
            return @rs.wiki.get(@scope.wikiId).then (wiki) =>
                @scope.wiki = wiki
                return wiki

        if @scope.project.my_permissions.indexOf("add_wiki_page") == -1
            return null

        data = {
            project: @scope.projectId
            slug: @scope.wikiSlug
            content: ""
        }
        @scope.wiki = @model.make_model("wiki", data)
        return @scope.wiki

    loadWikiLinks: ->
        return @rs.wiki.listLinks(@scope.projectId).then (wikiLinks) =>
            @scope.wikiLinks = wikiLinks

    loadInitialData: ->
        params = {
            pslug: @params.pslug
            wikipage: @params.slug
        }

        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        # Resolve wiki slug
        # This should be done in two steps because is not same thing
        # not found response for project and not found for wiki page
        # and they should be hendled separately.
        promise = promise.then =>
            prom = @repo.resolve({wikipage: @params.slug, pslug: @params.pslug})

            prom = prom.then (data) =>
                @scope.wikiId = data.wikipage

            return prom.then null, (xhr) =>
                @scope.wikiId = null

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @q.all([@.loadWikiLinks(),
                                       @.loadWiki()]))

    delete: ->
        # TODO: i18n
        title = "Delete Wiki Page"
        message = unslugify(@scope.wiki.slug)

        @confirm.askOnDelete(title, message).then (finish) =>
            onSuccess = =>
                finish()
                ctx = {project: @scope.projectSlug}
                @location.path(@navUrls.resolve("project-wiki", ctx))
                @confirm.notify("success")

            onError = =>
                finish(false)
                @confirm.notify("error")

            @repo.remove(@scope.wiki).then onSuccess, onError

module.controller("WikiDetailController", WikiDetailController)


#############################################################################
## Wiki Summary Directive
#############################################################################

WikiSummaryDirective = ($log) ->
    template = _.template("""
    <ul>
        <li>
            <span class="number"><%- totalEditions %></span>
            <span class="description">times <br />edited</span>
        </li>
        <li>
            <span class="number"><%- lastModifiedDate %></span>
            <span class="description"> last <br />edit</span>
        </li>
        <li class="username-edition">
            <figure class="avatar">
                <img src="<%- user.imgUrl %>" alt="<%- user.name %>">
            </figure>
            <span class="description">last modification</span>
            <span class="username"><%- user.name %></span>
        </li>
    </ul>
    """)

    link = ($scope, $el, $attrs, $model) ->
        render = (wiki) ->
            if not $scope.usersById?
                $log.error "WikiSummaryDirective requires userById set in scope."
            else
                user = $scope.usersById[wiki.last_modifier]

            if user is undefined
                user = {name: "unknown", imgUrl: "/images/unnamed.png"}
            else
                user = {name: user.full_name_display, imgUrl: user.photo}

            ctx = {
                totalEditions: wiki.editions
                lastModifiedDate: moment(wiki.modified_date).format("DD MMM YYYY HH:mm")
                user: user
            }
            html = template(ctx)
            $el.html(html)

        $scope.$watch $attrs.ngModel, (wikiPage) ->
            return if not wikiPage
            render(wikiPage)

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
    }

module.directive("tgWikiSummary", ["$log", WikiSummaryDirective])


#############################################################################
## Editable Wiki Content Directive
#############################################################################

EditableWikiContentDirective = ($window, $document, $repo, $confirm, $loading, $location, $navUrls,
                                $analytics) ->
    template = """
        <div class="view-wiki-content">
            <section class="wysiwyg"
                     tg-bind-html="wiki.html"></section>
            <span class="edit icon icon-edit" title="Edit"></span>
        </div>
        <div class="edit-wiki-content" style="display: none;">
            <textarea placeholder="Write your wiki page here"
                      ng-model="wiki.content"
                      tg-markitup="tg-markitup"></textarea>
            <span class="action-container">
                <a class="save icon icon-floppy" href="" title="Save" />
                <a class="cancel icon icon-delete" href="" title="Cancel" />
            </span>
        </div>
    """ # TODO: i18n

    link = ($scope, $el, $attrs, $model) ->
        isEditable = ->
            return $scope.project.my_permissions.indexOf("modify_wiki_page") != -1

        switchToEditMode = ->
            $el.find('.edit-wiki-content').show()
            $el.find('.view-wiki-content').hide()
            $el.find('textarea').focus()

        switchToReadMode = ->
            $el.find('.edit-wiki-content').hide()
            $el.find('.view-wiki-content').show()

        disableEdition = ->
            $el.find(".view-wiki-content .edit").remove()
            $el.find(".edit-wiki-content").remove()

        cancelEdition = ->
            if $scope.wiki.id
                $scope.wiki.revert()
                switchToReadMode()
            else
                ctx = {project: $scope.projectSlug}
                $location.path($navUrls.resolve("project-wiki", ctx))

        getSelectedText = ->
            if $window.getSelection
                return $window.getSelection().toString()
            else if $document.selection
                return $document.selection.createRange().text
            return null

        $el.on "mouseup", ".view-wiki-content", (event) ->
            # We want to dettect the a inside the div so we use the target and
            # not the currentTarget
            target = angular.element(event.target)
            return if not isEditable()
            return if target.is('a')
            return if getSelectedText()
            switchToEditMode()

        $el.on "click", ".save", debounce 2000, ->
            onSuccess = (wikiPage) ->
                if not $scope.wiki.id?
                    $analytics.trackEvent("wikipage", "create", "create wiki page", 1)

                $scope.wiki = wikiPage
                $model.setModelValue = $scope.wiki
                $confirm.notify("success")
                switchToReadMode()

            onError = ->
                $confirm.notify("error")

            $loading.start($el.find('.save-container'))
            if $scope.wiki.id?
                promise = $repo.save($scope.wiki).then(onSuccess, onError)
            else
                promise = $repo.create("wiki", $scope.wiki).then(onSuccess, onError)
            promise.finally ->
                $loading.finish($el.find('.save-container'))

        $el.on "click", ".cancel", ->
            cancelEdition()

        $el.on "keyup", "textarea", ->
            if event.keyCode == 27
                cancelEdition()

        $scope.$watch $attrs.ngModel, (wikiPage) ->
            return if not wikiPage
            $scope.wiki = wikiPage

            if isEditable()
                $el.addClass('editable')
                if not wikiPage.id?
                    switchToEditMode()
            else
                disableEdition()

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        restrict: "EA"
        require: "ngModel"
        template: template
    }

module.directive("tgEditableWikiContent", ["$window", "$document", "$tgRepo", "$tgConfirm", "$tgLoading",
                                           "$tgLocation", "$tgNavUrls", "$tgAnalytics",
                                           EditableWikiContentDirective])
