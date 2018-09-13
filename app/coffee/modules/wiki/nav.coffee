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
# File: modules/wiki/nav.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaWiki")


#############################################################################
## Wiki Main Directive
#############################################################################

WikiNavDirective = ($tgrepo, $log, $location, $confirm, $analytics, $loading, $template,
                    $compile, $translate) ->
    template = $template.get("wiki/wiki-nav.html", true)

    linkWikiLinks = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        if not $attrs.ngModel?
            return $log.error "WikiNavDirective: no ng-model attr is defined"

        addWikiLinkPermission = $scope.project.my_permissions.indexOf("add_wiki_link") > -1
        drake = null

        render = (wikiLinks) ->
            addWikiLinkPermission = $scope.project.my_permissions.indexOf("add_wiki_link") > -1
            deleteWikiLinkPermission = $scope.project.my_permissions.indexOf("delete_wiki_link") > -1

            html = template({
                wikiLinks: wikiLinks,
                projectSlug: $scope.projectSlug
                addWikiLinkPermission: addWikiLinkPermission
                deleteWikiLinkPermission: deleteWikiLinkPermission
            })

            html = $compile(html)($scope)

            $el.off()
            if addWikiLinkPermission and drake
                drake.destroy()

            $el.html(html)

            if addWikiLinkPermission
                itemEl = null
                tdom = $el.find(".sortable")

                drake = dragula([tdom[0]], {
                    direction: 'vertical',
                    copySortSource: false,
                    copy: false,
                    mirrorContainer: tdom[0],
                    moves: (item) -> return $(item).is('li')
                })

                drake.on 'dragend', (item) ->
                    itemEl = $(item)
                    item = itemEl.scope().link
                    itemIndex = itemEl.index()
                    $scope.$emit("wiki:links:move", item, itemIndex)

                scroll = autoScroll(window, {
                    margin: 20,
                    pixels: 30,
                    scrollWhenOutside: true,
                    autoScroll: () ->
                        return this.down && drake.dragging
                })

            $el.on "click", ".add-button", (event) ->
                event.preventDefault()
                $el.find(".new").removeClass("hidden")
                $el.find(".new input").focus()
                $el.find(".add-button").hide()

            $el.on "click", ".js-delete-link", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                linkId = target.parents('.wiki-link').data('id')

                title = $translate.instant("WIKI.DELETE_LINK_TITLE")
                message = $scope.wikiLinks[linkId].title

                $confirm.askOnDelete(title, message).then (askResponse) =>
                    promise = $tgrepo.remove($scope.wikiLinks[linkId])
                    promise.then ->
                        promise = $ctrl.loadWikiLinks()
                        promise.then ->
                            askResponse.finish()
                            render($scope.wikiLinks)
                        promise.then null, ->
                            askResponse.finish()
                    promise.then null, ->
                        askResponse.finish(false)
                        $confirm.notify("error")

            $el.on "keyup", ".new input", (event) ->
                event.preventDefault()
                if event.keyCode == 13
                    target = angular.element(event.currentTarget)
                    newLink = target.val()

                    currentLoading = $loading()
                        .target($el.find(".new"))
                        .start()

                    promise = $tgrepo.create("wiki-links", {project: $scope.projectId, title: newLink})
                    promise.then ->
                        $analytics.trackEvent("wikilink", "create", "create wiki link", 1)
                        loadPromise = $ctrl.loadWikiLinks()
                        loadPromise.then ->
                            currentLoading.finish()
                            $el.find(".new").addClass("hidden")
                            $el.find(".new input").val('')
                            $el.find(".add-button").show()
                            render($scope.wikiLinks)
                        loadPromise.then null, ->
                            currentLoading.finish()
                            $el.find(".new").addClass("hidden")
                            $el.find(".new input").val('')
                            $el.find(".add-button").show()
                            $confirm.notify("error", "Error loading wiki links")

                    promise.then null, (error) ->
                        currentLoading.finish()
                        $el.find(".new input").val(newLink)
                        $el.find(".new input").focus().select()
                        if error?.__all__?[0]?
                            $confirm.notify("error", "The link already exists")
                        else
                            $confirm.notify("error")

                else if event.keyCode == 27
                    target = angular.element(event.currentTarget)
                    $el.find(".new").addClass("hidden")
                    $el.find(".new input").val('')
                    $el.find(".add-button").show()

        bindOnce($scope, $attrs.ngModel, render)

    link = ($scope, $el, $attrs) ->
        linkWikiLinks($scope, $el, $attrs)

        $scope.$on "$destroy", ->
            $el.off()

    return {link:link}

module.directive("tgWikiNav", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", "$tgAnalytics",
                               "$tgLoading", "$tgTemplate", "$compile", "$translate", WikiNavDirective])
