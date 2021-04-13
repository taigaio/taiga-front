class CreateProjectController
    @.$inject = [
        "tgAppMetaService",
        "$translate",
        "tgProjectService",
        "$location",
        "$tgAuth"
    ]

    constructor: (@appMetaService, @translate, @projectService, @location, @authService) ->
        taiga.defineImmutableProperty @, "project", () => return @projectService.project

        @appMetaService.setfn @._setMeta.bind(this)

        @authService.refresh()

        @.displayScrumDesc = false
        @.displayKanbanDesc = false

    _setMeta: () ->
        return null if !@.project

        ctx = {projectName: @.project.get("name")}

        return {
            title: @translate.instant("PROJECT.PAGE_TITLE", ctx)
            description: @.project.get("description")
        }

    displayHelp: (type, $event) ->
        $event.stopPropagation()
        $event.preventDefault()

        if type == 'scrum'
            @.displayScrumDesc = !@.displayScrumDesc
        if type == 'kanban'
            @.displayKanbanDesc = !@.displayKanbanDesc


angular.module("taigaProjects").controller("CreateProjectCtrl", CreateProjectController)
