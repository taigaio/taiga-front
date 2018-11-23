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
# File: components/project-menu/project-menu.controller.coffee
###

class ProjectMenuController
    @.$inject = [
        "tgProjectService",
        "tgLightboxFactory"
    ]

    constructor: (@projectService, @lightboxFactory) ->
        @.project = null
        @.menu = Immutable.Map()

    show: () ->
        @.project = @projectService.project
        @.sprints = @.project.get('milestones')?.toJS()
        @.active = @._getActiveSection()

        @._setVideoConference()
        @._setMenuPermissions()

    hide: () ->
        @.project = null
        @.menu = {}

    search: () ->
        @lightboxFactory.create("tg-search-box", {
            "class": "lightbox lightbox-search"
        })

    _setVideoConference: () ->
        videoconferenceUrl = @._videoConferenceUrl()

        if videoconferenceUrl
            @.project = @.project.set("videoconferenceUrl", videoconferenceUrl)

    _setMenuPermissions: () ->
        @.menu = Immutable.Map({
            epics: false,
            backlog: false,
            kanban: false,
            issues: false,
            wiki: false
        })

        if @.project.get("is_epics_activated") && @.project.get("my_permissions").indexOf("view_epics") != -1
            @.menu = @.menu.set("epics", true)

        if @.project.get("is_backlog_activated") && @.project.get("my_permissions").indexOf("view_us") != -1
            @.menu = @.menu.set("backlog", true)

        if @.project.get("is_kanban_activated") && @.project.get("my_permissions").indexOf("view_us") != -1
            @.menu = @.menu.set("kanban", true)

        if @.project.get("is_issues_activated") && @.project.get("my_permissions").indexOf("view_issues") != -1
            @.menu = @.menu.set("issues", true)

        if @.project.get("is_wiki_activated") && @.project.get("my_permissions").indexOf("view_wiki_pages") != -1
            @.menu = @.menu.set("wiki", true)

    _getActiveSection: () ->
        sectionName = @projectService.section

        sectionsBreadcrumb = @projectService.sectionsBreadcrumb

        indexBacklog = sectionsBreadcrumb.lastIndexOf("backlog")
        indexKanban = sectionsBreadcrumb.lastIndexOf("kanban")

        if indexBacklog != -1 || indexKanban != -1
            if indexKanban == -1 || indexBacklog > indexKanban
                oldSectionName = "backlog"
            else
                oldSectionName = "kanban"

        if  sectionName  == "backlog-kanban"
            if oldSectionName in ["backlog", "kanban"]
                sectionName = oldSectionName
            else if @.project.get("is_backlog_activated") && !@.project.get("is_kanban_activated")
                sectionName = "backlog"
            else if !@.project.get("is_backlog_activated") && @.project.get("is_kanban_activated")
                sectionName = "kanban"

        return sectionName

    _videoConferenceUrl: () ->
        # Get base url
        if @.project.get("videoconferences") == "appear-in"
            baseUrl = "https://appear.in/"
        else if @.project.get("videoconferences") == "talky"
            baseUrl = "https://talky.io/"
        else if @.project.get("videoconferences") == "jitsi"
            baseUrl = "https://meet.jit.si/"
        else if @.project.get("videoconferences") == "custom"
            return @.project.get("videoconferences_extra_data")
        else
            return ""

        # Add prefix to the chat room name if exist
        if @.project.get("videoconferences_extra_data")
            url = @.project.get("slug") + "-" + taiga.slugify(@.project.get("videoconferences_extra_data"))
        else
            url = @.project.get("slug")

        # Some special cases
        if @.project.get("videoconferences") == "jitsi"
            url = url.replace(/-/g, "")

        return baseUrl + url

angular.module("taigaComponents").controller("ProjectMenu", ProjectMenuController)
