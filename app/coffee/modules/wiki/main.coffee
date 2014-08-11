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

module = angular.module("taigaWiki")

#############################################################################
## Wiki Detail Controller
#############################################################################

class WikiDetailController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.AttachmentsMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$location",
        "$filter",
        "$log"
    ]

    constructor: (@scope, @rootscope, @repo, @confirm, @rs, @params, @q, @location, @filter, @log) ->
        @.attachmentsUrlName = "wiki/attachments"

        @scope.projectSlug = @params.pslug
        @scope.wikiSlug = @params.slug
        @scope.sectionName = "Wiki"

        promise = @.loadInitialData()
        promise.then null, ->
            console.log "FAIL" #TODO

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.membersById = groupBy(project.memberships, (x) -> x.user)
            return project

    loadWikiSlug: ->
        params = {
            pslug: @params.pslug
            wikipage: @params.slug
        }

        promise = @repo.resolve(params).then (data) =>
            @scope.wikiId = data.wikipage
            @scope.projectId = data.project
            return data

          promise.then null, =>
            @location.path("/project/#{@params.pslug}/wiki/#{@params.slug}/edit")

    loadWiki: ->
        if @scope.wikiId
            return @rs.wiki.get(@scope.wikiId).then (wiki) =>
                @scope.wiki = wiki
        else
            return @scope.wiki = {
                content: ""
            }

    loadWikiLinks: ->
        return @rs.wiki.listLinks(@scope.projectId).then (wikiLinks) =>
            @scope.wikiLinks = wikiLinks

    loadInitialData: ->
        # Resolve project slug
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())
                      .then(=> @.loadUsersAndRoles())
                      .then(=> @.loadWikiLinks())
                      .then(=> @.loadWikiSlug())
                      .then(=> @.loadWiki())
                      .then(=> @.loadAttachments(@scope.wikiId))

    edit: ->
        @location.path("/project/#{@scope.projectSlug}/wiki/#{@scope.wikiSlug}/edit")

    cancel: ->
        @location.path("/project/#{@scope.projectSlug}/wiki/#{@scope.wikiSlug}")

    delete: ->
        onSuccess = =>
            @confirm.notify("success")
            @location.path("/project/#{@scope.projectSlug}/wiki")
        onError = =>
            @confirm.notify("error")


        # TODO: i18n
        title = "Delete Wiki Page"
        subtitle = unslugify(@scope.wiki.slug)

        @confirm.ask(title, subtitle).then =>
            @repo.remove(@scope.wiki).then onSuccess, onError

module.controller("WikiDetailController", WikiDetailController)

#############################################################################
## Wiki Edit Controller
#############################################################################

class WikiEditController extends WikiDetailController
    save: ->
        onSuccess = =>
            @confirm.notify("success")
            @location.path("/project/#{@scope.projectSlug}/wiki/#{@scope.wiki.slug}")

        onError = =>
            @confirm.notify("error")
            @location.path("/project/#{@scope.projectSlug}/wiki/#{@scope.wiki.slug}")

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
                ctx = {name: "Unassigned", imgurl: "/images/unnamed.png"}
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
