###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
