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
# File: services/project.service.spec.coffee
###

describe "tgProjectService", ->
    $provide = null
    $interval = null
    $rootScope = null
    $q = null
    mocks = {}
    projectService = null

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectBySlug: sinon.stub()
        }

        $provide.value "tgProjectsService", mocks.projectsService

    _mockUserActivityService = () ->
        mocks.userActivityService = {
            onInactive: sinon.stub(),
            onActive: sinon.stub()
        }

        $provide.value "tgUserActivityService", mocks.userActivityService

    _mockXhrErrorService = () ->
        mocks.xhrErrorService = {
            response: sinon.stub()
        }

        $provide.value "tgXhrErrorService", mocks.xhrErrorService

    _mocks = () ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockProjectsService()
            _mockXhrErrorService()
            _mockUserActivityService()

            return null

    _setup = () ->
        _mocks()

    _inject = () ->
        inject (_tgProjectService_, _$interval_, _$rootScope_, _$q_) ->
            projectService = _tgProjectService_
            $rootScope = _$rootScope_
            $q = _$q_
            $interval = _$interval_

    beforeEach ->
        module "taigaCommon"

        _setup()
        _inject()

    it "update section and add it at the begginning of section breadcrumb", () ->
        section = "fakeSection"
        breadcrumb = ["fakeSection"]

        projectService.setSection(section)

        expect(projectService.section).to.be.equal(section)
        expect(projectService.sectionsBreadcrumb.toJS()).to.be.eql(breadcrumb)

        section = "fakeSection222"
        breadcrumb = ["fakeSection", "fakeSection222"]
        projectService.setSection(section)

        expect(projectService.sectionsBreadcrumb.toJS()).to.be.eql(breadcrumb)

    it "set project if the project slug has changed", (done) ->
        projectService.setProject = sinon.spy()

        project = Immutable.Map({
            id: 1,
            slug: 'slug-1',
            members: []
        })

        getProjectBySlug1Deferred = $q.defer()
        mocks.projectsService.getProjectBySlug.withArgs('slug-1').returns(getProjectBySlug1Deferred.promise)
        getProjectBySlug1Deferred.resolve(project)

        getProjectBySlug2Deferred = $q.defer()
        mocks.projectsService.getProjectBySlug.withArgs('slug-2').returns(getProjectBySlug2Deferred.promise)
        getProjectBySlug2Deferred.resolve(project)

        projectService.setProjectBySlug('slug-1')
            .then () -> projectService.setProjectBySlug('slug-1')
            .then () -> projectService.setProjectBySlug('slug-2')
            .finally () ->
                expect(projectService.setProject).to.be.called.twice
                done()

        $rootScope.$apply()

    it "set project and set active members", () ->
        project = Immutable.fromJS({
            name: 'test project',
            members: [
                {is_active: true},
                {is_active: false},
                {is_active: true},
                {is_active: false},
                {is_active: false}
            ]
        })

        projectService.setProject(project)

        expect(projectService.project).to.be.equal(project)
        expect(projectService.activeMembers.size).to.be.equal(2)

    it "fetch project", (done) ->
        project = Immutable.Map({
            id: 1,
            slug: 'slug',
            members: []
        })

        projectService._project = project

        mocks.projectsService.getProjectBySlug.withArgs(project.get('slug')).promise().resolve(project)

        projectService.fetchProject().then () ->
            expect(projectService.project).to.be.equal(project)
            done()

    it "clean project", () ->
        projectService._section = "fakeSection"
        projectService._sectionsBreadcrumb = ["fakeSection"]
        projectService._activeMembers = ["fakeMember"]
        projectService._project = Immutable.Map({
            id: 1,
            slug: 'slug',
            members: []
        })

        projectService.cleanProject()

        expect(projectService.project).to.be.null
        expect(projectService.activeMembers.size).to.be.equal(0)
        expect(projectService.section).to.be.null
        expect(projectService.sectionsBreadcrumb.size).to.be.equal(0)

    it "has permissions", () ->
        project = Immutable.Map({
            id: 1,
            my_permissions: [
                'test1',
                'test2'
            ]
        })

        projectService._project = project

        perm1 = projectService.hasPermission('test2')
        perm2 = projectService.hasPermission('test3')

        expect(perm1).to.be.true
        expect(perm2).to.be.false

    it "autorefresh project interval", () ->
        projectService.fetchProject = sinon.spy()

        expect(projectService.fetchProject).not.to.have.been.called

        $interval.flush(60 * 11 * 1000)

        expect(projectService.fetchProject).to.have.been.called

    it "cancel interval on user inactivity", () ->
        $interval.cancel = sinon.spy()

        projectService.fetchProject = sinon.spy()

        expect($interval.cancel).not.to.have.been.called

        mocks.userActivityService.onInactive.callArg(0)

        expect($interval.cancel).to.have.been.called

    it "fech project if the user restars the activity", () ->
        projectService.fetchProject = sinon.spy()
        projectService.autoRefresh = sinon.spy()

        expect(projectService.fetchProject).not.to.have.been.called
        expect(projectService.autoRefresh).not.to.have.been.called

        mocks.userActivityService.onActive.callArg(0)

        expect(projectService.fetchProject).to.have.been.called
        expect(projectService.autoRefresh).to.have.been.called
