FavItemDirective = ->
    link = (scope, el, attrs, ctrl) ->
        scope.vm = {item: scope.item}

    templateUrl = (el, attrs) ->
        if attrs.itemType == "project"
            return "profile/profile-favs/items/project.html"
        else # if attr.itemType in ["userstory", "task", "issue"]
            return "profile/profile-favs/items/ticket.html"

    return {
        scope: {
            "item": "=tgFavItem"
        }
        link: link
        templateUrl: templateUrl
    }


angular.module("taigaProfile").directive("tgFavItem", FavItemDirective)
