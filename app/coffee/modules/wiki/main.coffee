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
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgLocation",
        "$filter",
        "$log",
        "$appTitle",
        "$tgNavUrls",
        "tgLoader"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @filter, @log, @appTitle,
                  @navUrls, tgLoader) ->
        @scope.projectSlug = @params.pslug
        @scope.wikiSlug = @params.slug
        @scope.sectionName = "Wiki"

        promise = @.loadInitialData()

        # On Success
        promise.then () =>
            @appTitle.set("Wiki - " + @scope.project.name)
            tgLoader.pageLoaded()

        # On Error
        promise.then null, (xhr) =>
            if xhr and xhr.status == 404
                @location.path(@navUrls.resolve("not-found"))
                @location.replace()
            return @q.reject(xhr)

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

        @scope.wiki = {content: ""}
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
                ctx = {project: @params.pslug, slug: @params.slug}
                @location.path(@navUrls.resolve("project-wiki-page-edit", ctx))

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @q.all([@.loadWikiLinks(),
                                       @.loadWiki()]))

    edit: ->
        ctx = {
            project: @scope.projectSlug
            slug: @scope.wikiSlug
        }
        @location.path(@navUrls.resolve("project-wiki-page-edit", ctx))

    cancel: ->
        ctx = {
            project: @scope.projectSlug
            slug: @scope.wikiSlug
        }
        @location.path(@navUrls.resolve("project-wiki-page", ctx))

    delete: ->
        # TODO: i18n
        title = "Delete Wiki Page"
        subtitle = unslugify(@scope.wiki.slug)

        @confirm.ask(title, subtitle).then (finish) =>
            onSuccess = =>
                finish()
                ctx = {project: @scope.projectSlug}
                @location.path(@navUrls.resolve("project-wiki", ctx))
                @confirm.notify("success")

            onError = =>
                @confirm.notify("error")

            @repo.remove(@scope.wiki).then onSuccess, onError

module.controller("WikiDetailController", WikiDetailController)

#############################################################################
## Wiki Edit Controller
#############################################################################

class WikiEditController extends WikiDetailController
    save: debounce 2000, ->
        onSuccess = =>
            ctx = {
                project: @scope.projectSlug
                slug: @scope.wiki.slug
            }
            @location.path(@navUrls.resolve("project-wiki-page", ctx))
            @confirm.notify("success")

        onError = =>
            @confirm.notify("error")

        if @scope.wiki.id
            @repo.save(@scope.wiki).then onSuccess, onError
        else
            @scope.wiki.project = @scope.projectId
            @scope.wiki.slug = @scope.wikiSlug
            @repo.create("wiki", @scope.wiki).then onSuccess, onError

module.controller("WikiEditController", WikiEditController)


#############################################################################
## Wiki Main Directive
#############################################################################

WikiDirective = ($tgrepo, $log, $location, $confirm) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

    return {link:link}

module.directive("tgWikiDetail", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", WikiDirective])


#############################################################################
## Wiki Edit Main Directive
#############################################################################

WikiEditDirective = ($tgrepo, $log, $location, $confirm) ->
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

    return {link:link}

module.directive("tgWikiEdit", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", WikiEditDirective])


#############################################################################
## Wiki User Info Directive
#############################################################################

WikiUserInfoDirective = ($log) ->
    template = _.template("""
    <figure class="avatar">
        <img src="<%= imgurl %>" alt="<%- name %>">
    </figure>
    <span class="description">last modification</span>
    <span class="username"><%- name %></span>
    """)

    link = ($scope, $el, $attrs) ->
        if not $attrs.ngModel?
            return $log.error "WikiUserDirective: no ng-model attr is defined"

        render = (wiki) ->
            if not $scope.usersById?
                $log.error "WikiUserDirective requires userById set in scope."
            else
                user = $scope.usersById[wiki.last_modifier]
            if user is undefined
                ctx = {name: "unknown", imgurl: "/images/unnamed.png"}
            else
                ctx = {name: user.full_name_display, imgurl: user.photo}

            html = template(ctx)
            $el.html(html)

        bindOnce($scope, $attrs.ngModel, render)

    return {
        link: link
        restrict: "AE"
    }

module.directive("tgWikiUserInfo", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", WikiUserInfoDirective])
