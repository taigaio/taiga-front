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
# File: services/avatar.service.coffee
###

class AvatarService
    constructor: (@config) ->
        IMAGES = [
            "/#{window._version}/images/user-avatars/user-avatar-01.png"
            "/#{window._version}/images/user-avatars/user-avatar-02.png"
            "/#{window._version}/images/user-avatars/user-avatar-03.png"
            "/#{window._version}/images/user-avatars/user-avatar-04.png"
            "/#{window._version}/images/user-avatars/user-avatar-05.png"
        ]

        COLORS = [
            "rgba( 178, 176, 204, 1 )"
            "rgba( 183, 203, 131, 1 )"
            "rgba( 210, 198, 139, 1 )"
            "rgba( 214, 161, 212, 1 )"
            "rgba( 247, 154, 154, 1 )"
        ]

        @.logos = _.cartesianProduct(IMAGES, COLORS)

    getDefault: (key) ->
        idx = murmurhash3_32_gc(key, 42) %% @.logos.length
        logo = @.logos[idx]

        return { src: logo[0], color: logo[1] }

    getUnnamed: () ->
        return {
            url: "/#{window._version}/images/unnamed.png"
            username: ''
        }

    getAvatar: (user, type) ->
        return @.getUnnamed() if !user

        avatarParamName = 'photo'

        if type == 'avatarBig'
            avatarParamName = 'big_photo'

        photo = null

        if user instanceof Immutable.Map
            gravatar = user.get('gravatar_id')
            photo = user.get(avatarParamName)
            username = "@#{user.get('username')}"
        else
            gravatar = user.gravatar_id
            photo = user[avatarParamName]
            username = "@#{user.username}"

        return @.getUnnamed() if !gravatar

        if photo
            return {
                url: photo,
                username: username
            }
        else if location.host.indexOf('localhost') != -1 || !@config.get("gravatar", true)
            root = location.protocol + '//' + location.host
            logo = @.getDefault(gravatar)

            return {
                url: root + logo.src,
                bg: logo.color,
                username: username
            }
        else
            root = location.protocol + '//' + location.host
            logo = @.getDefault(gravatar)

            logoUrl = encodeURIComponent(root + logo.src)

            return {
                url: 'https://www.gravatar.com/avatar/' + gravatar + "?s=200&d=" + logoUrl,
                bg: logo.color,
                username: username
            }

angular.module("taigaCommon").service("tgAvatarService", ["$tgConfig", AvatarService])
