taiga = @.taiga

class CheckPermissionsService
    @.$inject = [
        "tgProjectService"
    ]

    constructor: (@projectService) ->

    check: (permission) ->
        return false if !@projectService.project

        return @projectService.project.get('my_permissions').indexOf(permission) != -1

angular.module("taigaCommon").service("tgCheckPermissionsService", CheckPermissionsService)
