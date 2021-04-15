###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

AvatarDirective = (avatarService) ->
    link = (scope, el, attrs) ->
        if attrs.tgAvatarBig
            attributeName = 'avatarBig'
        else
            attributeName = 'avatar'

        scope.$watch attributeName, (user) ->
            avatar = avatarService.getAvatar(user, attributeName)

            el.attr('src', avatar.url)
            el.attr('title', "#{avatar.fullName}")
            el.attr('alt', "#{avatar.fullName}")
            el.css('background', avatar.bg or "")

    return {
        link: link
        scope: {
            avatar: "=tgAvatar"
            avatarBig: "=tgAvatarBig"
        }
    }

AvatarDirective.$inject = [
    'tgAvatarService'
]

angular.module("taigaComponents").directive("tgAvatar", AvatarDirective)
angular.module("taigaComponents").directive("tgAvatarBig", AvatarDirective)
