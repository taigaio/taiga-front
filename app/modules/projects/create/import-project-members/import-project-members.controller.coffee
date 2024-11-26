###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class ImportProjectMembersController
    @.$inject = [
        'tgCurrentUserService',
        'tgUserService'
    ]

    constructor: (@currentUserService, @userService) ->
        @.selectImportUserLightbox = false
        @.warningImportUsers = false
        @.displayEmailSelector = true
        @.cancelledUsers = Immutable.List()
        @.selectedUsers = Immutable.List()
        @.selectableUsers = Immutable.List()
        @.userContacts = Immutable.List()

    fetchUser: () ->
        @.currentUser = @currentUserService.getUser()

        @userService.getContacts(@.currentUser.get('id')).then (userContacts) =>
            @.userContacts = userContacts
            @.refreshSelectableUsers()

    searchUser: (user) ->
        @.selectImportUserLightbox = true
        @.searchingUser = user

    beforeSubmitUsers: () ->
        if @.selectedUsers.size != @.members.size
            @.warningImportUsers = true
        else
            @.submit()

    confirmUser: (externalUser, taigaUser) ->
        @.selectImportUserLightbox = false

        user = Immutable.Map()
        user = user.set('user', externalUser)
        user = user.set('taigaUser', taigaUser)

        @.selectedUsers = @.selectedUsers.push(user)

        @.discardSuggestedUser(externalUser)

        @.refreshSelectableUsers()

    unselectUser: (user) ->
        index = @.selectedUsers.findIndex (it) -> it.getIn(['user', 'id']) == user.get('id')

        @.selectedUsers = @.selectedUsers.delete(index)
        @.refreshSelectableUsers()

    discardSuggestedUser: (member) ->
        @.cancelledUsers = @.cancelledUsers.push(member.get('id'))

    getSelectedMember: (member) ->
        return @.selectedUsers.find (it) ->
            return it.getIn(['user', 'id']) == member.get('id')

    isMemberSelected: (member) ->
        return !!@.getSelectedMember(member)

    getUser: (user) ->
        userSelected = @.getSelectedMember(user)

        if userSelected
            return userSelected.get('taigaUser')
        else
            return null

    submit: () ->
        @.warningImportUsers = false

        users = Immutable.Map()

        @.selectedUsers.map (it) ->
            id = ''

            if _.isString(it.get('taigaUser'))
                id = it.get('taigaUser')
            else
                id = it.getIn(['taigaUser', 'id'])

            users = users.set(it.getIn(['user', 'id']), id)

        @.onSubmit({users: users})

    checkUsersLimit: () ->
        @.limitMembersPrivateProject = @currentUserService.canAddMembersPrivateProject(@.members.size + 1)
        @.limitMembersPublicProject = @currentUserService.canAddMembersPublicProject(@.members.size + 1)

    showSuggestedMatch: (member) ->
        return member.get('user') && @.cancelledUsers.indexOf(member.get('id')) == -1 && !@.isMemberSelected(member)

    getDistinctSelectedTaigaUsers: () ->
        ids = []

        users = @.selectedUsers.filter (it) ->
            id = it.getIn(['taigaUser', 'id'])

            if ids.indexOf(id) == -1
                ids.push(id)
                return true

            return false

        return users.filter (it) =>
            return it.getIn(['taigaUser', 'id']) != @.currentUser.get('id')

    refreshSelectableUsers: () ->
        @.importMoreUsersDisabled = @.isImportMoreUsersDisabled()

        if @.importMoreUsersDisabled
            users = @.getDistinctSelectedTaigaUsers()

            @.selectableUsers = users.map (it) -> return it.get('taigaUser')
            @.displayEmailSelector = false
        else
            @.selectableUsers = @.userContacts
            @.displayEmailSelector = true

        @.selectableUsers = @.selectableUsers.push(@.currentUser)

    isImportMoreUsersDisabled: () ->
        users = @.getDistinctSelectedTaigaUsers()

        # currentUser + newUser = +2
        total = users.size + 2


        if @.project.get('is_private')
            return !@currentUserService.canAddMembersPrivateProject(total).valid
        else
            return !@currentUserService.canAddMembersPublicProject(total).valid

angular.module('taigaProjects').controller('ImportProjectMembersCtrl', ImportProjectMembersController)
