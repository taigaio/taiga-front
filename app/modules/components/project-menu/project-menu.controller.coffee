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
            backlog: false,
            kanban: false,
            issues: false,
            wiki: false
        })

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
            if indexKanban == -1 || indexBacklog < indexKanban
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
        if @.project.get("videoconferences") == "appear-in"
            baseUrl = "https://appear.in/"
        else if @.project.get("videoconferences") == "talky"
            baseUrl = "https://talky.io/"
        else if @.project.get("videoconferences") == "jitsi"
            baseUrl = "https://meet.jit.si/"
            url = @.project.get("slug") + "-" + taiga.slugify(@.project.get("videoconferences_salt"))
            url = url.replace(/-/g, "")
            return baseUrl + url
        else
            return ""

        if @.project.get("videoconferences_salt")
            url = @.project.get("slug") + "-" + @.project.get("videoconferences_salt")
        else
            url = @.project.get("slug")

        return baseUrl + url

angular.module("taigaComponents").controller("ProjectMenu", ProjectMenuController)
