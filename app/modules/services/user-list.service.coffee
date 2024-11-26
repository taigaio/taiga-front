###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
normalizeString = @.taiga.normalizeString

class UserListService
    @.$inject = [
        "tgCurrentUserService"
        "tgProjectService"
    ]

    constructor: (@currentUserService, @projectService) ->

    filterUsers: (text, user) ->
        username = user.full_name_display.toUpperCase()
        username = normalizeString(username)
        text = text.toUpperCase()
        text = normalizeString(text)
        return _.includes(username, text)

    searchUsers: (text, excludedUser) ->
        @.currentUser = @currentUserService.getUser()
        users = _.clone(@projectService.activeMembers.toJS(), true)
        users = _.reject(users, {"id": excludedUser.id}) if excludedUser
        users = _.sortBy(users, (o) => if o.id is @.currentUser?.get('id') then 0 else o.id)
        users = _.filter(users, _.partial(@.filterUsers, text)) if text?
        return users

angular.module("taigaCommon").service("tgUserListService", UserListService)
