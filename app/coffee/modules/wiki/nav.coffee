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
# File: modules/wiki/detail.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
groupBy = @.taiga.groupBy
bindOnce = @.taiga.bindOnce

module = angular.module("taigaWiki")


#############################################################################
## Wiki Main Directive
#############################################################################

WikiNavDirective = ($tgrepo, $log, $location, $confirm, $navUrls, $analytics, $loading, $template, $compile, $translate) ->
    template = $template.get("wiki/wiki-nav.html", true)
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        if not $attrs.ngModel?
            return $log.error "WikiNavDirective: no ng-model attr is defined"

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
            $el.html(html)

            $el.on "click", ".wiki-link .link-title", (event) ->
                event.preventDefault()
                target = angular.element(event.currentTarget)
                linkId = target.parents('.wiki-link').data('id')
                linkSlug = $scope.wikiLinks[linkId].href
                $scope.$apply ->
                    ctx = {
                        project: $scope.projectSlug
                        slug: linkSlug
                    }
                    $location.path($navUrls.resolve("project-wiki-page", ctx))

            $el.on "click", ".add-button", (event) ->
                event.preventDefault()
                $el.find(".new").removeClass("hidden")
                $el.find(".new input").focus()
                $el.find(".add-button").hide()

            $el.on "click", ".wiki-link .icon-delete", (event) ->
                event.preventDefault()
                event.stopPropagation()
                target = angular.element(event.currentTarget)
                linkId = target.parents('.wiki-link').data('id')

                title = $translate.instant("WIKI.DELETE_LIGHTBOX_TITLE")
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

    return {link:link}

module.directive("tgWikiNav", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", "$tgNavUrls",
                               "$tgAnalytics", "$tgLoading", "$tgTemplate", "$compile", "$translate", WikiNavDirective])
