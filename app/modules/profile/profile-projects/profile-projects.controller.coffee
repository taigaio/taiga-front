class ProfileProjectsController
    @.$inject = [
        "tgProjectsService",
        "tgUserService"
    ]

    constructor: (@projectsService, @userService) ->

    loadProjects: () ->
        @projectsService.getProjectsByUserId(@.user.get("id"))
            .then (projects) =>
                return @userService.attachUserContactsToProjects(@.user.get("id"), projects)
            .then (projects) =>
                @.projects = projects

angular.module("taigaProfile")
    .controller("ProfileProjects", ProfileProjectsController)
