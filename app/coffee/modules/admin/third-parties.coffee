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
# File: modules/admin/memberships.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce

module = angular.module("taigaAdmin")


#############################################################################
## Github Controller
#############################################################################

class GithubController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "$tgRepo",
        "$tgResources",
        "$routeParams",
        "$q",
        "$tgNavUrls",
        "$appTitle"
    ]

    constructor: (@scope, @repo, @rs, @params, @q, @navUrls, @appTitle) ->
        _.bindAll(@)

        @scope.sectionName = "Github" #i18n
        @scope.project = {}
        @scope.anyComputableRole = true

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Github - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

    loadProject: ->
        return @rs.projects.get(@scope.projectId).then (project) =>
            @scope.project = project
            @scope.$emit('project:loaded', project)
            @scope.anyComputableRole = _.some(_.map(project.roles, (point) -> point.computable))

            return project

    loadInitialData: ->
        promise = @repo.resolve({pslug: @params.pslug}).then (data) =>
            @scope.projectId = data.project
            return data

        return promise.then(=> @.loadProject())


module.controller("GithubController", GithubController)


SelectInputText =  ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", ".select-input-content", () ->
            $el.find("input").select()
            $el.find(".help-copy").addClass("visible")

    return {link:link}

module.directive("tgSelectInputText", SelectInputText)
