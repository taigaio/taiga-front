###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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

    _mockTgProjectService = () ->
        mocks.projectService = {
            project: Immutable.fromJS({id: 2})
        }
        provide.value "tgProjectService", mocks.projectService

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
            _mockTgProjectService()

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
