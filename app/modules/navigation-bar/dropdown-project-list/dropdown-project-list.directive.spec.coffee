###
# Copyright (C) 2014-2018 Taiga Agile LLC
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
# File: navigation-bar/dropdown-project-list/dropdown-project-list.directive.spec.coffee
###

describe "dropdownProjectListDirective", () ->
    scope = compile = provide = null
    mocks = {}
    template = "<div tg-dropdown-project-list></div>"
    recents = []

    projects = Immutable.fromJS({
        recents: [
            {id: 1},
            {id: 2},
            {id: 3}
        ]
    })

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgProjectsService = () ->
        mocks.projectsService = {
            newProject: sinon.stub()
        }
        provide.value "tgProjectsService", mocks.projectsService

    _mockTgCurrentUserService = () ->
        mocks.currentUserService = {
            projects: projects
        }
        provide.value "tgCurrentUserService", mocks.currentUserService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgProjectsService()
            _mockTgCurrentUserService()
            _mockTranslateFilter()

            return null

    beforeEach ->
        module "templates"
        module "taigaNavigationBar"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "dropdown project list directive scope content", () ->
        elm = createDirective()
        scope.$apply()
        expect(elm.isolateScope().vm.projects.size).to.be.equal(3)
