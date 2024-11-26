###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

groupBy = @.taiga.groupBy

class CurrentUserService
    @.$inject = [
        "tgProjectsService",
        "$tgStorage",
        "tgResources",
        "$q"
    ]

    constructor: (@projectsService, @storageService, @rs, @q) ->
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
        @._joyride = null

    setUser: (user) ->
        @._user = user
        return @._loadUserInfo()

    bulkUpdateProjectsOrder: (sortData) ->
        @projectsService.bulkUpdateProjectsOrder(sortData).then () =>
            @.loadProjects()

    loadProjects: () ->
        return @projectsService.getProjectsByUserId(@._user.get("id"))
            .then (projects) => @.setProjects(projects)

    loadProjectsList: () ->
        return @projectsService.getListProjectsByUserId(@._user.get("id"), null,)
            .then (projects) => @.setProjects(projects)

    disableJoyRide: (section) ->
        if !@.isAuthenticated()
            return

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
        return @q (resolve) =>
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
        return @q.all([
            @.loadProjectsList()
        ])

    setProjects: (projects) ->
        @._projects = @._projects.set("all", projects)
        @._projects = @._projects.set("recents", projects.slice(0, 4))
        @._projects = @._projects.set("unblocked",
                                      projects.filter((project) -> project.toJS().blocked_code == null))

        @._projectsById = Immutable.fromJS(groupBy(projects.toJS(), (p) -> p.id))

        return @.projects

    canCreatePrivateProjects: () ->
        user = @.getUser()
        if user.get('max_private_projects') != null &&
            user.get('total_private_projects') >= user.get('max_private_projects')
                return {
                    valid: false,
                    reason: 'max_private_projects',
                    type: 'private_project',
                    current: user.get('total_private_projects'),
                    max: user.get('max_private_projects')
                }

        return {valid: true}

    canCreatePublicProjects: () ->
        user = @.getUser()

        if user && user.get('max_public_projects') != null &&
            user.get('total_public_projects') >= user.get('max_public_projects')
                return {
                    valid: false,
                    reason: 'max_public_projects',
                    type: 'public_project',
                    current: user.get('total_public_projects'),
                    max: user.get('max_public_projects')
                }

        return {valid: true}

    canAddMembersPublicProject: (totalMembers) ->
        user = @.getUser()

        if user.get('max_memberships_public_projects') != null &&
            totalMembers > user.get('max_memberships_public_projects')
                return {
                    valid: false,
                    reason: 'max_members_public_projects',
                    type: 'public_project',
                    current: totalMembers,
                    max: user.get('max_memberships_public_projects')
                }

        return {valid: true}

    canAddMembersPrivateProject: (totalMembers) ->
        user = @.getUser()

        if user.get('max_memberships_private_projects') != null &&
            totalMembers > user.get('max_memberships_private_projects')
                return {
                    valid: false,
                    reason: 'max_members_private_projects',
                    type: 'private_project',
                    current: totalMembers,
                    max: user.get('max_memberships_private_projects')
                }

        return {valid: true}

    canOwnProject: (project) ->
        user = @.getUser()
        if project.get('is_private')
            result = @.canCreatePrivateProjects()
            return result if !result.valid

            membersResult = @.canAddMembersPrivateProject(project.get('total_memberships'))
            return membersResult if !membersResult.valid
        else
            result = @.canCreatePublicProjects()
            return result if !result.valid

            membersResult = @.canAddMembersPublicProject(project.get('total_memberships'))
            return membersResult if !membersResult.valid

        return {valid: true}

angular.module("taigaCommon").service("tgCurrentUserService", CurrentUserService)
