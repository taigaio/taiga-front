class ProfileProjectsController
    @.$inject = [
        "tgProjectsService",
        "tgUserService",
        "$tgAuth"
    ]

    constructor: (@projectsService, @userService, @auth) ->

    loadProjects: () ->
        userId = @auth.getUser().id

        @projectsService.getProjectsByUserId(userId)
            .then (projects) =>
                return @userService.attachUserContactsToProjects(userId, projects)
            .then (projects) =>
                @.projects = projects

angular.module("taigaProfile")
    .controller("ProfileProjects", ProfileProjectsController)
