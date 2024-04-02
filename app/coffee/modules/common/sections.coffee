###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
