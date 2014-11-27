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
# File: modules/admin/third-parties.coffee
###

taiga = @.taiga

mixOf = @.taiga.mixOf
bindMethods = @.taiga.bindMethods

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
        "$appTitle"
    ]

    constructor: (@scope, @repo, @rs, @params, @appTitle) ->
        bindMethods(@)

        @scope.sectionName = "Github" #i18n
        @scope.project = {}
        @scope.anyComputableRole = true

        promise = @.loadInitialData()

        promise.then () =>
            @appTitle.set("Github - " + @scope.project.name)

        promise.then null, @.onInitialDataError.bind(@)

    loadModules: ->
        return @rs.modules.list(@scope.projectId, "github").then (github) =>
            @scope.github = github

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
                      .then(=> @.loadModules())


module.controller("GithubController", GithubController)

SelectInputText =  ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", ".select-input-content", () ->
            $el.find("input").select()
            $el.find(".help-copy").addClass("visible")

    return {link:link}

module.directive("tgSelectInputText", SelectInputText)

#############################################################################
## GithubWebhooks Directive
#############################################################################

GithubWebhooksDirective = ($repo, $confirm, $loading) ->
    link = ($scope, $el, $attrs) ->
        form = $el.find("form").checksley({"onlyOneErrorElement": true})
        submit = (target) =>
            return if not form.validate()

            $loading.start(target)

            promise = $repo.saveAttribute($scope.github, "github")
            promise.then ->
                $loading.finish(target)
                $confirm.notify("success")

            promise.then null, (data) ->
                $loading.finish(target)
                form.setErrors(data)
                if data._error_message
                    $confirm.notify("error", data._error_message)

        $el.on "click", "a.button-green", (event) ->
            event.preventDefault()
            target = angular.element(event.currentTarget)
            submit(target)

        $el.on "submit", "form", (event) ->
            event.preventDefault()
            submit()

    return {link:link}

module.directive("tgGithubWebhooks", ["$tgRepo", "$tgConfirm", "$tgLoading", GithubWebhooksDirective])
