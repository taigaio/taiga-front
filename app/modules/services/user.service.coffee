taiga = @.taiga

class UserService extends taiga.Service
    @.$inject = ["$tgResources"]

    constructor: (@rs) ->

    getProjects: (userId) ->
        return @rs.projects.listByMember(userId)
            .then (projects) -> return Immutable.fromJS(projects)

    attachUserContactsToProjects: (userId, projects) ->
        return @rs.users.contacts(userId)
            .then (contacts) -> return Immutable.fromJS(contacts)
            .then (contacts) ->
                projects = projects.map (project) ->
                    project.contacts = contacts.filter (contact) ->
                        return project.members.indexOf(contact.id) != -1

                    return project

                return projects

angular.module("taigaCommon").service("tgUserService", UserService)
