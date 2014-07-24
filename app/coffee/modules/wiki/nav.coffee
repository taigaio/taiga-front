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
slugify = @.taiga.slugify

module = angular.module("taigaWiki")

#############################################################################
## Wiki Main Directive
#############################################################################

WikiNavDirective = ($tgrepo, $log, $location, $confirm) ->
    template = _.template("""
    <header>
      <h1>Links</h1>
    </header>
    <nav>
      <ul>
        <% _.each(wikiLinks, function(link, index) { %>
        <li class="wiki-link" data-id="<%- index %>">
          <a title="<%- link.title %>">
              <span class="link-title"><%- link.title %></span>
              <span class="icon icon-delete"></span>
          </a>
          <input type="text" placeholder="name" class="hidden" value="<%- link.title %>" />
        </li>
        <% }) %>
        <li class="new hidden">
          <input type="text" placeholder="name"/>
        </li>
      </ul>
    </nav>
    <a href="" title="Add link" class="add-button button button-gray">Add link</a>
    """)
    link = ($scope, $el, $attrs) ->
        $ctrl = $el.controller()

        if not $attrs.ngModel?
            return $log.error "WikiNavDirective: no ng-model attr is defined"

        render = (wikiLinks) ->
            html = template({wikiLinks: wikiLinks, projectSlug: $scope.projectSlug})

            $el.off()
            $el.html(html)

            $el.on "click", ".wiki-link .link-title", (event) ->
                event.preventDefault()
                target = angular.element(event.currentTarget)
                linkId = target.parents('.wiki-link').data('id')
                linkSlug = $scope.wikiLinks[linkId].href
                $scope.$apply ->
                    $location.path("/project/#{$scope.projectSlug}/wiki/#{linkSlug}")

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
                $tgrepo.remove($scope.wikiLinks[linkId]).then ->
                    $ctrl.loadWikiLinks().then ->
                        render($scope.wikiLinks)

            $el.on "keyup", ".new input", (event) ->
                event.preventDefault()
                if event.keyCode == 13
                    target = angular.element(event.currentTarget)
                    newLink = target.val()

                    $el.find(".new").addClass("hidden")
                    $el.find(".new input").val('')

                    $tgrepo.create("wiki-links", {project: $scope.projectId, title: newLink, href: slugify(newLink)}).then ->
                        $ctrl.loadWikiLinks().then ->
                            render($scope.wikiLinks)
                    $el.find(".add-button").show()

                else if event.keyCode == 27
                    target = angular.element(event.currentTarget)
                    $el.find(".new").addClass("hidden")
                    $el.find(".new input").val('')
                    $el.find(".add-button").show()


        bindOnce($scope, $attrs.ngModel, render)

    return {link:link}

module.directive("tgWikiNav", ["$tgRepo", "$log", "$tgLocation", "$tgConfirm", WikiNavDirective])
