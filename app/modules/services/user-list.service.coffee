###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: services/user-list.service.coffee
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
