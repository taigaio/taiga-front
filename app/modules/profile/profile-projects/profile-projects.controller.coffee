class ProfileProjectsController
    @.$inject = [
        "tgProjectsService",
        "tgUserService"
    ]

    constructor: (@projectsService, @userService) ->

    loadProjects: () ->
        @projectsService.getProjectsByUserId(@.userId)
            .then (projects) =>
                return @userService.attachUserContactsToProjects(@.userId, projects)
            .then (projects) =>
                @.projects = projects

angular.module("taigaProfile")
    .controller("ProfileProjects", ProfileProjectsController)
