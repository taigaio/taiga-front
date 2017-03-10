###
# Copyright (C) 2014-2015 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2015 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2015 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: live-announcement.directive.coffee
###


LiveAnnouncementDirective = (liveAnnouncementService) ->
    link = (scope, el, attrs) ->

    return {
        restrict: "AE",
        scope: {},
        controllerAs: 'vm',
        controller: () ->
            this.close = () ->
                liveAnnouncementService.open = false

            Object.defineProperties(this, {
                open: {
                    get: () -> return liveAnnouncementService.open
                },
                title: {
                    get: () -> return liveAnnouncementService.title
                },
                desc: {
                    get: () -> return liveAnnouncementService.desc
                }
            })
        link: link,
        templateUrl: "components/live-announcement/live-announcement.html"
    }

LiveAnnouncementDirective.$inject = [
    "tgLiveAnnouncementService"
]

angular.module("taigaComponents")
    .directive("tgLiveAnnouncement", LiveAnnouncementDirective)
