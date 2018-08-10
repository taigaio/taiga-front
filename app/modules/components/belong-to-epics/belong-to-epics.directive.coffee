###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: belong-to-epics.directive.coffee
###

module = angular.module('taigaEpics')

BelongToEpicsDirective = ($translate, $confirm, $rs, $rs2, lightboxService) ->

    link = (scope, el, attrs) ->
        scope.$watch 'epics', (epics) ->
            updateEpics(epics)

        scope.$on "related-epics:changed", (ctx, userStory)->
            $rs.userstories.getByRef(userStory.project, userStory.ref, {}).then (us) ->
                scope.item.epics = us.epics
                updateEpics(us.epics)

        scope.removeEpicRelationship = (epic) ->
            title = $translate.instant("LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.TITLE")
            message = $translate.instant(
                "LIGHTBOX.REMOVE_RELATIONSHIP_WITH_EPIC.MESSAGE",
                { epicSubject:  epic.get('subject') }
            )

            $confirm.ask(title, null, message).then (askResponse) ->
                onSuccess = ->
                    askResponse.finish()
                    scope.$broadcast("related-epics:changed", scope.item)

                onError = ->
                    askResponse.finish(false)
                    $confirm.notify("error")

                epicId = epic.get('id')
                usId = scope.item.id
                $rs2.epics.deleteRelatedUserstory(epicId, usId).then(onSuccess, onError)

        updateEpics = (epics) ->
            scope.epicsLength = 0
            scope.immutable_epics = []
            if epics && !epics.isIterable
                scope.epicsLength = epics.length
                scope.immutable_epics = Immutable.fromJS(epics)

    templateUrl = (el, attrs) ->
        if attrs.format
            return "components/belong-to-epics/belong-to-epics-" + attrs.format + ".html"
        return "components/belong-to-epics/belong-to-epics-pill.html"

    return {
        link: link,
        scope: {
            epics: '=',
            item: "="
        },
        templateUrl: templateUrl
    }


module.directive("tgBelongToEpics", [
    "$translate", "$tgConfirm", "$tgResources", "tgResources", "lightboxService",
    BelongToEpicsDirective])
