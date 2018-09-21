###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/common/sections.coffee
###

module = angular.module("taigaCommon")

SECTIONS = {
    1: {id: 1, title: 'TIMELINE', path:'timeline'}
    2: {id: 2, title: 'SEARCH', path:'search'}
    3: {id: 3, title: 'EPICS', path:'epics'}
    4: {id: 4, title: 'BACKLOG', path:'backlog'}
    5: {id: 5, title: 'KANBAN', path:'kanban'}
    6: {id: 6, title: 'ISSUES', path:'issues'}
    7: {id: 7, title: 'WIKI', path:'wiki'}
    8: {id: 8, title: 'TEAM', path:'team'}
    9: {id: 9, title: 'MEETUP', path:'meetup'}
    10: {id: 10, title: 'ADMIN', path:'admin'}
}

class SectionsService extends taiga.Service
    @.$inject = ["$translate"]

    constructor: (@translate) ->
        super()
        _.map(SECTIONS, (x) => x.title = @translate.instant("PROJECT.SECTION.#{x.title}"))
    list: () ->
        return SECTIONS

module.service("$tgSections", SectionsService)
