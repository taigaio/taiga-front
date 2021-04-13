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
