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
# File: projects/create/create-project-form/create-project-form.controller.coffee
###

class CreatetProjectFormController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
        "$projectUrl",
        "$location",
        "$tgNavUrls",
        "$tgAnalytics"
   ]

    constructor: (@currentUserService, @projectsService, @projectUrl, @location, @navUrls, @analytics) ->
        @.projectForm = {
            is_private: false
        }

        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        if !@.canCreatePublicProjects.valid && @.canCreatePrivateProjects.valid
            @.projectForm.is_private = true

        if @.type == 'scrum'
            @.projectForm.creation_template = 1
        else
            @.projectForm.creation_template = 2

    submit: () ->
        @.formSubmitLoading = true

        @projectsService.create(@.projectForm).then (project) =>
            @analytics.trackEvent("project", "create", "project creation", {slug: project.get('slug'), id: project.get('id')})
            @location.url(@projectUrl.get(project))
            @currentUserService.loadProjects()

    onCancelForm: () ->
        @location.path(@navUrls.resolve("create-project"))

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid
        else
            return @.canCreatePublicProjects.valid

    isDisabled: () ->
        return @.formSubmitLoading || !@.canCreateProject()

angular.module('taigaProjects').controller('CreateProjectFormCtrl', CreatetProjectFormController)
