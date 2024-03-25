###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
