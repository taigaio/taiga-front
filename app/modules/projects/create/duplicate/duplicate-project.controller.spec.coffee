###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
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
# File: home.controller.spec.coffee
###

describe "DuplicateProjectController", ->
    ctrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockCurrentUserService = () ->
        mocks.currentUserService = {}
        mocks.currentUserService.getUser = sinon.stub()
        mocks.currentUserService.canCreatePublicProjects = sinon.stub().returns(true)
        mocks.currentUserService.canCreatePrivateProjects = sinon.stub().returns(true)

        mocks.currentUserService.projects = {}
        mocks.currentUserService.projects.get = sinon.stub()

        mocks.currentUserService.loadProjects = sinon.stub()

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mockProjectService = () ->
        mocks.projectsService = {}
        mocks.projectsService.getProjectBySlug = sinon.stub()
        mocks.projectsService.duplicate = sinon.stub()

        provide.value "tgProjectsService", mocks.projectsService

    _mockLocation = () ->
        mocks.location = {
            path: sinon.stub()
        }
        provide.value "$tgLocation", mocks.location

    _mockTgNav = () ->
        mocks.urlservice = {
            resolve: sinon.stub()
        }
        provide.value "$tgNavUrls", mocks.urlservice

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockCurrentUserService()
            _mockProjectService()
            _mockLocation()
            _mockTgNav()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

        ctrl = controller "DuplicateProjectCtrl"

        ctrl.projects = Immutable.fromJS([
            {
                id: 1
            },
            {
                id: 2
            }
        ])



        ctrl.canCreatePublicProjects = mocks.currentUserService.canCreatePublicProjects()
        ctrl.canCreatePrivateProjects = mocks.currentUserService.canCreatePublicProjects()
        ctrl.duplicatedProject = {}

    it "get project to duplicate", () ->

        project = Immutable.fromJS({
            members: [
                {id: 1},
                {id: 2},
                {id: 3}
            ]
        })

        slug = 'slug'
        ctrl._getInvitedMembers = sinon.stub()

        promise = mocks.projectsService.getProjectBySlug.withArgs(slug).promise().resolve(project)

        ctrl.getReferenceProject(slug).then () ->
            expect(ctrl.referenceProject).to.be.equal(project)
            expect(ctrl.invitedMembers).to.be.equal(project.get('members'))
            expect(ctrl._getInvitedMembers).to.be.calledWith(ctrl.invitedMembers)

    it 'get Invited members', () ->
        membersBefore = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])
        membersAfter = Immutable.fromJS([
            {id: 2},
            {id: 3}
        ])

        ctrl.setInvitedMembers = sinon.spy()
        ctrl.checkUsersLimit = sinon.spy()

        ctrl._getInvitedMembers(membersBefore)
        expect(ctrl.invitedMembers.toJS()).to.be.eql(membersAfter.toJS())
        expect(ctrl.setInvitedMembers).to.be.calledWith(ctrl.invitedMembers)
        expect(ctrl.checkUsersLimit).to.be.calledWith(ctrl.invitedMembers)

    it 'set Invited members', () ->
        ctrl.duplicatedProject = {}
        members = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])
        membersList = Immutable.fromJS([1, 2, 3])

        ctrl.checkUsersLimit = sinon.spy()

        ctrl.setInvitedMembers(members)
        expect(ctrl.duplicatedProject.users).to.be.eql(membersList)
        expect(ctrl.checkUsersLimit).to.be.calledWith(members)

    it 'user can invite more members in private project', () ->
        members = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])
        size = members.size #3

        ctrl.user = Immutable.fromJS({
            max_memberships_public_projects: 100
            max_memberships_private_projects: 100
        })

        ctrl.duplicatedProject = {}
        ctrl.duplicatedProject.is_private = true

        ctrl.checkUsersLimit(members)
        expect(ctrl.limitMembersPublicProject).to.be.false
        expect(ctrl.limitMembersPrivateProject).to.be.false

    it 'user cannot invite more members in private project', () ->
        members = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])
        size = members.size #3

        ctrl.user = Immutable.fromJS({
            max_memberships_public_projects: 1
            max_memberships_private_projects: 1
        })

        ctrl.duplicatedProject = {}
        ctrl.duplicatedProject.is_private = true

        ctrl.checkUsersLimit(members)
        expect(ctrl.limitMembersPublicProject).to.be.false
        expect(ctrl.limitMembersPrivateProject).to.be.true

    it 'user can invite more members in public project', () ->
        members = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])
        size = members.size #3

        ctrl.user = Immutable.fromJS({
            max_memberships_public_projects: 100
            max_memberships_private_projects: 100
        })

        ctrl.duplicatedProject = {}
        ctrl.duplicatedProject.is_private = false

        ctrl.checkUsersLimit(members)
        expect(ctrl.limitMembersPrivateProject).to.be.false
        expect(ctrl.limitMembersPublicProject).to.be.false

    it 'user cannot invite more members in public project', () ->
        members = Immutable.fromJS([
            {id: 1},
            {id: 2},
            {id: 3}
        ])
        size = members.size #3

        ctrl.user = Immutable.fromJS({
            max_memberships_public_projects: 1
            max_memberships_private_projects: 1
        })

        ctrl.duplicatedProject = {}
        ctrl.duplicatedProject.is_private = false

        ctrl.checkUsersLimit(members)
        expect(ctrl.limitMembersPrivateProject).to.be.false
        expect(ctrl.limitMembersPublicProject).to.be.true

    it 'duplicate project', (done) ->

        ctrl.referenceProject = Immutable.fromJS({
            id: 1
        })
        ctrl.duplicatedProject = Immutable.fromJS({
            id: 1
        })
        projectId = ctrl.referenceProject.get('id')
        data = ctrl.duplicatedProject

        newProject = {}
        newProject.data = {
            slug: 'slug'
        }

        mocks.urlservice.resolve.withArgs("project", {project: newProject.data.slug}).returns("/project/slug/")

        promise = mocks.projectsService.duplicate.withArgs(projectId, data).promise().resolve(newProject)

        ctrl.onDuplicateProject().then () ->
            expect(ctrl.loading).to.be.false
            expect(mocks.location.path).to.be.calledWith("/project/slug/")
            expect(mocks.currentUserService.loadProjects).to.have.been.called
            done()
