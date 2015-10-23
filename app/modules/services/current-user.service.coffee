taiga = @.taiga

groupBy = @.taiga.groupBy

class CurrentUserService
    @.$inject = [
        "tgProjectsService",
        "$tgStorage",
        "tgResources"
    ]

    constructor: (@projectsService, @storageService, @rs) ->
        @._user = null
        @._projects = Immutable.Map()
        @._projectsById = Immutable.Map()
        @._joyride = null

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
            @.loadProjects()

    loadProjects: () ->
        return @projectsService.getProjectsByUserId(@._user.get("id"))
            .then (projects) => @.setProjects(projects)

    disableJoyRide: (section) ->
        if section
            @._joyride[section] = false
        else
            @._joyride = {
                backlog: false,
                kanban: false,
                dashboard: false
            }

        @rs.user.setUserStorage('joyride', @._joyride)

    loadJoyRideConfig: () ->
        return new Promise (resolve) =>
            if @._joyride != null
                resolve(@._joyride)
                return

            @rs.user.getUserStorage('joyride')
                .then (config) =>
                    @._joyride = config
                    resolve(@._joyride)
                .catch () =>
                    #joyride not defined
                    @._joyride = {
                        backlog: true,
                        kanban: true,
                        dashboard: true
                    }

                    @rs.user.createUserStorage('joyride', @._joyride)

                    resolve(@._joyride)

    _loadUserInfo: () ->
        return Promise.all([
            @.loadProjects()
        ])

    setProjects: (projects) ->
        @._projects = @._projects.set("all", projects)
        @._projects = @._projects.set("recents", projects.slice(0, 10))

        @._projectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

        return @.projects

angular.module("taigaCommon").service("tgCurrentUserService", CurrentUserService)
