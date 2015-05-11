class ProfileProjectsController
    @.$inject = [
        "tgUserService",
        "$tgAuth"
    ]

    constructor: (@userService, @auth) ->

    loadProjects: () ->
        userId = @auth.getUser().id

        @userService.getProjects(userId)
            .then (projects) =>
                return @userService.attachUserContactsToProjects(userId, projects)
            .then (projects) =>
                @.projects = projects

angular.module("taigaProfile")
    .controller("ProfileProjects", ProfileProjectsController)
