taiga = @.taiga

class ChekcPermissionsService
    @.$inject = [
        "tgProjectService"
    ]

    constructor: (@projectService) ->

    check: (permission) ->
        return @projectService.project.get('my_permissions').indexOf(permission) != -1

angular.module("taigaCommon").service("tgCheckPermissionsService", ChekcPermissionsService)
