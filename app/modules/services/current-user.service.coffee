taiga = @.taiga

groupBy = @.taiga.groupBy

class CurrentUserService
    @.$inject = [
        "tgProjectsService",
        "$tgStorage"
    ]

    constructor: (@projectsService, @storageService) ->
        @._user = Immutable.Map()
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()

        taiga.defineImmutableProperty @, "projects", () => return @._projects
        taiga.defineImmutableProperty @, "projectsById", () => return @._projectsById

    getUser: () ->
        if !@._user.size
            userData = @storageService.get("userInfo")
            userData = Immutable.fromJS(userData)
            @.setUser(userData) if userData

        return @._user

    setUser: (user) ->
        @._user = user

        return @._loadUserInfo()

    _loadProjects: () ->
        return @projectsService.getProjectsByUserId(@._user.get("id"))
            .then (projects) =>
                @._projects = @._projects.set("all", projects)
                @._projects = @._projects.set("recents", projects.slice(0, 10))

                @._projectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

                return @.projects

    _loadUserInfo: () ->
        return @._loadProjects()

angular.module("taigaCommon").service("tgCurrentUserService", CurrentUserService)
