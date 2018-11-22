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
# File: services/project.service.coffee
###

taiga = @.taiga

class ProjectService
    @.$inject = [
        "$rootScope",
        "tgProjectsService",
        "tgXhrErrorService",
        "tgUserActivityService",
        "$interval"
    ]

    constructor: (@rootScope,  @projectsService, @xhrError, @userActivityService, @interval) ->
        @._project = null
        @._section = null
        @._sectionsBreadcrumb = Immutable.List()
        @._activeMembers = Immutable.List()

        taiga.defineImmutableProperty @, "project", () => return @._project
        taiga.defineImmutableProperty @, "section", () => return @._section
        taiga.defineImmutableProperty @, "sectionsBreadcrumb", () => return @._sectionsBreadcrumb
        taiga.defineImmutableProperty @, "activeMembers", () => return @._activeMembers

        @.autoRefresh() if !window.localStorage.e2e
        @.watchSignals()

    watchSignals: () ->
        fetchRequiredSignals = [
            "admin:project-modules:updated"
            "admin:project-roles:updated"
            "admin:project-default-values:updated"
            "admin:project-values:updated"
            "admin:project-values:move"
            "admin:project-custom-attributes:updated"
            "tags:updated"
        ]
        for signal in fetchRequiredSignals
            @rootScope.$on(signal, @.manageProjectSignal)

    manageProjectSignal: (ctx) =>
        @.fetchProject()

    cleanProject: () ->
        @._project = null
        @._activeMembers = Immutable.List()
        @._section = null
        @._sectionsBreadcrumb = Immutable.List()

    autoRefresh: () ->
        intervalId = @interval () =>
            @.fetchProject()
        , 60 * 10 * 1000

        @userActivityService.onInactive () => @interval.cancel(intervalId)
        @userActivityService.onActive () =>
            @.fetchProject()
            @.autoRefresh()

    setSection: (section) ->
        @._section = section

        if section
            @._sectionsBreadcrumb = @._sectionsBreadcrumb.push(@._section)
        else
            @._sectionsBreadcrumb = Immutable.List()

    setProject: (project) ->
        @._project = project
        @._activeMembers = @._project.get('members').filter (member) -> member.get('is_active')

    setProjectBySlug: (pslug) ->
        return new Promise (resolve, reject) =>
            if !@.project || @.project.get('slug') != pslug
                @projectsService
                    .getProjectBySlug(pslug)
                    .then (project) =>
                        @.setProject(project)
                        resolve()
                    .catch (xhr) =>
                        @xhrError.response(xhr)

            else resolve()

    fetchProject: () ->
        return if !@.project

        pslug = @.project.get('slug')

        return @projectsService.getProjectBySlug(pslug).then (project) => @.setProject(project)

    hasPermission: (permission) ->
        return @._project.get('my_permissions').indexOf(permission) != -1

    isEpicsDashboardEnabled: ->
        return @._project.get("is_epics_activated")

angular.module("taigaCommon").service("tgProjectService", ProjectService)
