taiga = @.taiga

groupBy = @.taiga.groupBy

class CurrentUserService
    @.$inject = [
        "tgProjectsService",
        "$tgStorage"
    ]

    constructor: (@projectsService, @storageService) ->
        @._user = null
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()

        taiga.defineImmutableProperty @, "projects", () => return @._projects
        taiga.defineImmutableProperty @, "projectsById", () => return @._projectsById

    isAuthenticated: ->
        if @.getUser() != null
            return true
        return false

    getUser: () ->
        if !@._user
            userData = @storageService.get("userInfo")

            if userData
                userData = Immutable.fromJS(userData)
                @.setUser(userData)

        return @._user

    removeUser: () ->
        @._user = null
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()

    setUser: (user) ->
        @._user = user

        return @._loadUserInfo()

    bulkUpdateProjectsOrder: (sortData) ->
        @projectsService.bulkUpdateProjectsOrder(sortData).then () =>
            @._loadProjects()

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
