###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProjectRouterController
    @.$inject = [
        "$routeParams",
        "$location"
        "tgProjectService"
        "$tgResources"
        "$tgSections"
    ]

    constructor: (@routeParams, @location, @projectService, @rs, @tgSections) ->
        @getProjectHomepage()
            .then (section) =>
                if section
                    @location.url("project/#{@routeParams.pslug}/#{section}")
                else
                    @gotoDefaultProjectHomepage()
            .then null, ->
                @gotoDefaultProjectHomepage()

    gotoDefaultProjectHomepage: () ->
        @location.url("project/#{@routeParams.pslug}/timeline")

    getProjectHomepage: () ->
        project = @projectService.project.toJS()

        @rs.userProjectSettings.list({project: project.id}).then (userProjectSettings) =>
            settings = _.find(userProjectSettings, {"project": project.id})
            return if !settings

            return @tgSections.getPath(project.slug, settings.homepage)

angular.module("taigaProjects").controller("ProjectRouter", ProjectRouterController)
