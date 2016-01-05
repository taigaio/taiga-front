###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: project.service.coffee
###

taiga = @.taiga

class ProjectService
    @.$inject = [
        "tgProjectsService",
        "tgXhrErrorService"
    ]

    constructor: (@projectsService, @xhrError) ->
        @._project = null
        @._section = null
        @._sectionsBreadcrumb = Immutable.List()
        @._activeMembers = Immutable.List()

        taiga.defineImmutableProperty @, "project", () => return @._project
        taiga.defineImmutableProperty @, "section", () => return @._section
        taiga.defineImmutableProperty @, "sectionsBreadcrumb", () => return @._sectionsBreadcrumb
        taiga.defineImmutableProperty @, "activeMembers", () => return @._activeMembers

    setSection: (section) ->
        @._section = section

        if section
            @._sectionsBreadcrumb = @._sectionsBreadcrumb.push(@._section)
        else
            @._sectionsBreadcrumb = Immutable.List()

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

    setProject: (project) ->
        @._project = project
        @._activeMembers = @._project.get('members').filter (member) -> member.get('is_active')

    cleanProject: () ->
        @._project = null
        @._activeMembers = Immutable.List()
        @._section = null
        @._sectionsBreadcrumb = Immutable.List()

    fetchProject: () ->
        pslug = @.project.get('slug')

        return @projectsService.getProjectBySlug(pslug).then (project) => @.setProject(project)

angular.module("taigaCommon").service("tgProjectService", ProjectService)
