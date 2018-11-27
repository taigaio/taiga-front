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

class SectionsService extends taiga.Service
    @.$inject = ["$translate", "tgCurrentUserService"]

    SECTIONS = {
        1: {id: 1, title: 'TIMELINE', path:'timeline', enabled: ''}
        2: {id: 2, title: 'EPICS', path:'epics', enabled: 'is_epics_activated'}
        3: {id: 3, title: 'BACKLOG', path:'backlog', enabled: 'is_backlog_activated'}
        4: {id: 4, title: 'KANBAN', path:'kanban', enabled: 'is_kanban_activated'}
        5: {id: 5, title: 'ISSUES', path:'issues', enabled: 'is_issues_activated'}
        6: {id: 6, title: 'WIKI', path:'wiki', enabled: 'is_wiki_activated'}
    }

    constructor: (@translate, @currentUserService) ->
        super()
        _.map(SECTIONS, (x) => x.title = @translate.instant("PROJECT.SECTION.#{x.title}"))
    list: () ->
        return SECTIONS
    getPath: (projectSlug, sectionId) ->
        defaultHomePage = "timeline"

        projects = @currentUserService.projects?.get("all")
        if not projects
            return defaultHomePage

        project = projects.find (p) -> return p.get('slug') == projectSlug
        if not project
            return defaultHomePage

        if not sectionId
            sectionId = project.get('my_homepage')

        section = _.find(SECTIONS, {"id": sectionId})
        if !section or project?.get(section.enabled) is not true
            return defaultHomePage

        return section.path

module.service("$tgSections", SectionsService)
