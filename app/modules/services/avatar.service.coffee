###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

class AvatarService
    constructor: (@config) ->
        IMAGES = [
            "#{window._version}/images/user-avatars/user-avatar-01.png"
            "#{window._version}/images/user-avatars/user-avatar-02.png"
            "#{window._version}/images/user-avatars/user-avatar-03.png"
            "#{window._version}/images/user-avatars/user-avatar-04.png"
            "#{window._version}/images/user-avatars/user-avatar-05.png"
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
            url: "#{window._version}/images/unnamed.png"
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
            fullName = user.get('full_name_display')
        else
            gravatar = user.gravatar_id
            photo = user[avatarParamName]
            username = "@#{user.username}"
            fullName = user.full_name_display

        return @.getUnnamed() if !gravatar

        if photo
            return {
                url: photo,
                username: username,
                fullName: fullName
            }
        else if location.host.indexOf('localhost') != -1 || !@config.get("gravatar", true)
            root = location.protocol + '//' + location.host + @config.get('baseHref')
            logo = @.getDefault(gravatar)

            return {
                url: root + logo.src,
                bg: logo.color,
                username: username,
                fullName: fullName
            }
        else
            root = location.protocol + '//' + location.host + @config.get('baseHref')
            logo = @.getDefault(gravatar)

            logoUrl = encodeURIComponent(root + logo.src)

            return {
                url: 'https://www.gravatar.com/avatar/' + gravatar + "?s=200&d=" + logoUrl,
                bg: logo.color,
                username: username,
                fullName: fullName
            }

angular.module("taigaCommon").service("tgAvatarService", ["$tgConfig", AvatarService])
