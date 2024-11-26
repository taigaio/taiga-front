###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce
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
        "tgAppMetaService",
        "$tgNavUrls",
        "$tgAnalytics",
        "$translate",
        "tgErrorHandlingService",
        "tgProjectService",
        "tgAttachmentsFullService",
    ]

    constructor: (@scope, @rootscope, @repo, @model, @confirm, @rs, @params, @q, @location,
                  @filter, @log, @appMetaService, @navUrls, @analytics, @translate, @errorHandlingService, @projectService, @attachmentsFullService) ->
        @scope.$on("wiki:links:move", @.moveLink)
        @scope.$on("wikipage:add", @.loadWiki)
        @scope.projectSlug = @params.pslug
        @scope.wikiSlug = @params.slug
        @scope.sectionName = "Wiki"
        @scope.linksVisible = false
        @scope.attachmentsReady = false
        @scope.$on "attachments:loaded", () =>
            @scope.attachmentsReady = true

        promise = @.loadInitialData()

        # On Success
        promise.then () => @._setMeta()

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    _setMeta: ->
        title =  @translate.instant("WIKI.PAGE_TITLE", {
            wikiPageName: @scope.wikiSlug
            projectName: @scope.project.name
        })
        description =  @translate.instant("WIKI.PAGE_DESCRIPTION", {
            wikiPageContent: angular.element(@scope.wiki?.html or "").text()
            totalEditions: @scope.wiki?.editions or 0
            lastModifiedDate: moment(@scope.wiki?.modified_date).format(@translate.instant("WIKI.DATETIME"))
        })

        @appMetaService.setAll(title, description)

    loadAttachments: ->
        @attachmentsFullService.loadAttachments('wikipage', @scope.wikiId, @scope.projectId)

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.is_wiki_activated
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)
        return project

    loadWiki: =>
        promise = @rs.wiki.getBySlug(@scope.projectId, @params.slug)
        promise.then (wiki) =>
            @scope.wiki = wiki
            @scope.wikiId = wiki.id

            @.loadAttachments()

            return @scope.wiki

        promise.then null, (xhr) =>
            @scope.wikiId = null
            @scope.attachmentsReady = true

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

            for link in @scope.wikiLinks
                link.url = @navUrls.resolve("project-wiki-page", {
                    project: @scope.projectSlug
                    slug: link.href
                })

            selectedWikiLink = _.find(wikiLinks, {href: @scope.wikiSlug})

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        @q.all([@.loadWikiLinks(), @.loadWiki()]).then @.checkLinksPerms.bind(this)

    checkLinksPerms: ->
        if @scope.project.my_permissions.indexOf("add_wiki_link") != -1 ||
          (@scope.project.my_permissions.indexOf("view_wiki_links") != -1 && @scope.wikiLinks.length)
            @scope.linksVisible = true

    delete: ->
        title = @translate.instant("WIKI.DELETE_LIGHTBOX_TITLE")
        message = @scope.wikiSlug

        @confirm.askOnDelete(title, message).then (askResponse) =>
            onSuccess = =>
                askResponse.finish()
                ctx = {project: @scope.projectSlug}
                @location.path(@navUrls.resolve("project-wiki", ctx))
                @confirm.notify("success")
                @.loadWiki()

            onError = =>
                askResponse.finish(false)
                @confirm.notify("error")

            @repo.remove(@scope.wiki).then onSuccess, onError

    moveLink: (ctx, item, itemIndex) =>
        values = @scope.wikiLinks
        r = values.indexOf(item)
        values.splice(r, 1)
        values.splice(itemIndex, 0, item)
        _.each values, (value, index) ->
            value.order = index

        @repo.saveAll(values)

module.controller("WikiDetailController", WikiDetailController)


#############################################################################
## Wiki Summary Directive
#############################################################################

WikiSummaryDirective = ($log, $template, $compile, $translate, avatarService) ->
    template = $template.get("wiki/wiki-summary.html", true)

    link = ($scope, $el, $attrs, $model) ->
        render = (wiki) ->
            if not $scope.usersById?
                $log.error "WikiSummaryDirective requires userById set in scope."
            else
                user = $scope.usersById[wiki.last_modifier]

            avatar = avatarService.getAvatar(user)

            if user is undefined
                user = {name: "unknown", avatar: avatar}
            else
                user = {name: user.full_name_display, avatar: avatar}

            ctx = {
                totalEditions: wiki.editions
                lastModifiedDate: moment(wiki.modified_date).format($translate.instant("WIKI.DATETIME"))
                user: user
            }
            html = template(ctx)
            html = $compile(html)($scope)
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

module.directive("tgWikiSummary", ["$log", "$tgTemplate", "$compile", "$translate",  "tgAvatarService", WikiSummaryDirective])

WikiWysiwyg = ($modelTransform, $rootscope, $confirm, attachmentsFullService,
$qqueue, $repo, $analytics, activityService) ->
    link = ($scope, $el, $attrs) ->
        $scope.editableDescription = false

        $scope.saveDescription = $qqueue.bindAdd (description, cb) ->
            onSuccess = (wikiPage) ->
                if not $scope.item.id?
                    $analytics.trackEvent("wikipage", "create", "create wiki page", 1)
                    $scope.$emit("wikipage:add")
                    $scope.editableDescription = $scope.project.my_permissions.indexOf("modify_wiki_page") != -1

                activityService.fetchEntries(true)
                $confirm.notify("success")

            onError = ->
                $confirm.notify("error")

            $scope.item.content =  description

            if $scope.item.id?
                promise = $repo.save($scope.item).then(onSuccess, onError)
            else
                promise = $repo.create("wiki", $scope.item).then(onSuccess, onError)

            promise.finally(cb)

        $scope.uploadFiles = (file, cb) ->
            attachmentsFullService.addAttachment($scope.project.id, $scope.item.id, 'wiki_page', file).then (result) ->
                cb({
                    default: result.getIn(['file', 'url'])
                })

            return

        $scope.$watch $attrs.model, (value) ->
            return if not value
            $scope.item = value
            $scope.version = value.version
            $scope.storageKey = $scope.project.id + "-" + value.id + "-wiki"

        $scope.$watch 'project', (project) ->
            return if !project

            if $scope.item.id?
                $scope.editableDescription = project.my_permissions.indexOf("modify_wiki_page") != -1
            else
                $scope.editableDescription = project.my_permissions.indexOf("add_wiki_page") != -1

    return {
        scope: true,
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    ng-if="editableDescription"
                    html-read-mode="true"
                    placeholder="'COMMON.DESCRIPTION.EMPTY '| translate"
                    version='version'
                    project="project"
                    storage-key='storageKey'
                    content='item.content'
                    on-save='saveDescription(text, cb)'
                    on-upload-file='uploadFiles'>
                </tg-wysiwyg>

                <div
                    class="wysiwyg"
                    ng-if="!editableDescription && item.content.length"
                    tg-bind-wysiwyg-html="item.content"></div>
                <div
                    class="wysiwyg"
                    ng-if="!editableDescription && !item.content.length">
                    {{'COMMON.DESCRIPTION.NO_DESCRIPTION' | translate}}
                </div>
            </div>
        """
    }

module.directive("tgWikiWysiwyg", [
    "$tgQueueModelTransformation",
    "$rootScope",
    "$tgConfirm",
    "tgAttachmentsFullService",
    "$tgQqueue", "$tgRepo", "$tgAnalytics", "tgActivityService"
    WikiWysiwyg])
