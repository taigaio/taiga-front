###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: modules/wiki/pages-list.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf

module = angular.module("taigaWiki")

#############################################################################
## Wiki Pages List Controller
#############################################################################

class WikiPagesListController extends mixOf(taiga.Controller, taiga.PageMixin)
    @.$inject = [
        "$scope",
        "$rootScope",
        "$tgRepo",
        "$tgModel",
        "$tgConfirm",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgNavUrls",
        "tgErrorHandlingService",
        "tgProjectService"
    ]

    constructor: (@scope, @rootscope, @repo, @model, @confirm, @rs, @params, @q,
                  @navUrls, @errorHandlingService, @projectService) ->
        @scope.projectSlug = @params.pslug
        @scope.wikiSlug = @params.slug
        @scope.sectionName = "Wiki"
        @scope.linksVisible = false

        promise = @.loadInitialData()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.is_wiki_activated
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)

        return project

    loadWikiPages: ->
        promise = @rs.wiki.list(@scope.projectId).then (wikipages) =>
            @scope.wikipages = wikipages

    loadWikiLinks: ->
        return @rs.wiki.listLinks(@scope.projectId).then (wikiLinks) =>
            @scope.wikiLinks = wikiLinks

            for link in @scope.wikiLinks
                link.url = @navUrls.resolve("project-wiki-page", {
                    project: @scope.projectSlug
                    slug: link.href
                })

            selectedWikiLink = _.find(wikiLinks, {href: @scope.wikiSlug})

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)

        @q.all([@.loadWikiLinks(), @.loadWikiPages()]).then(@.checkLinksPerms.bind(this))

    checkLinksPerms: ->
        if @scope.project.my_permissions.indexOf("add_wiki_link") != -1 ||
          (@scope.project.my_permissions.indexOf("view_wiki_links") != -1 && @scope.wikiLinks.length)
            @scope.linksVisible = true

module.controller("WikiPagesListController", WikiPagesListController)
