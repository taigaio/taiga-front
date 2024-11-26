###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
