###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
        mocks.currentUserService.projects.get = sinon.stub().returns([])

        mocks.currentUserService.loadProjects = sinon.stub()

        mocks.currentUserService.canAddMembersPrivateProject = sinon.stub()
        mocks.currentUserService.canAddMembersPublicProject = sinon.stub()

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

        ctrl.user = Immutable.fromJS([
            {
                id: 1
            }
        ])

        ctrl.canCreatePublicProjects = mocks.currentUserService.canCreatePublicProjects()
        ctrl.canCreatePrivateProjects = mocks.currentUserService.canCreatePublicProjects()
        ctrl.projectForm = {}

    it "toggle invited Member", () ->
        ctrl = controller "DuplicateProjectCtrl"

        ctrl.invitedMembers = Immutable.List([1, 2, 3])
        ctrl.checkUsersLimit = sinon.spy()

        ctrl.toggleInvitedMember(2)

        expect(ctrl.invitedMembers.toJS()).to.be.eql([1, 3])

        ctrl.toggleInvitedMember(5)

        expect(ctrl.invitedMembers.toJS()).to.be.eql([1, 3, 5])

        expect(ctrl.checkUsersLimit).to.have.been.called

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

        ctrl.refreshReferenceProject(slug).then () ->
            expect(ctrl.referenceProject).to.be.equal(project)
            expect(ctrl.members.toJS()).to.be.eql(project.get('members').toJS())
            expect(ctrl.invitedMembers.toJS()).to.be.eql([1, 2, 3])

    it 'check users limits', () ->
        mocks.currentUserService.canAddMembersPrivateProject.withArgs(4).returns(1)
        mocks.currentUserService.canAddMembersPublicProject.withArgs(4).returns(2)

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

        ctrl.projectForm = {}
        ctrl.projectForm.is_private = false
        ctrl.invitedMembers = members

        ctrl.checkUsersLimit()
        expect(ctrl.limitMembersPrivateProject).to.be.equal(1)
        expect(ctrl.limitMembersPublicProject).to.be.equal(2)

    it 'duplicate project', (done) ->
        ctrl.referenceProject = Immutable.fromJS({
            id: 1
        })
        ctrl.projectForm = Immutable.fromJS({
            id: 1
        })
        projectId = ctrl.referenceProject.get('id')
        data = ctrl.projectForm

        newProject = {}
        newProject.data = {
            slug: 'slug'
        }

        mocks.urlservice.resolve.withArgs("project", {project: newProject.data.slug}).returns("/project/slug/")

        promise = mocks.projectsService.duplicate.withArgs(projectId, data).promise().resolve(newProject)

        ctrl.submit().then () ->
            expect(ctrl.formSubmitLoading).to.be.false
            expect(mocks.location.path).to.be.calledWith("/project/slug/")
            expect(mocks.currentUserService.loadProjects).to.have.been.called
            done()

    it 'check if the user can create a private projects', () ->
        mocks.currentUserService.canCreatePrivateProjects = sinon.stub().returns({valid: true})

        ctrl = controller "DuplicateProjectCtrl"
        ctrl.limitMembersPrivateProject = {valid: true}

        ctrl.projectForm = {
            is_private: true
        }

        expect(ctrl.canCreateProject()).to.be.true

        mocks.currentUserService.canCreatePrivateProjects = sinon.stub().returns({valid: false})

        ctrl = controller "DuplicateProjectCtrl"

        ctrl.projectForm = {
            is_private: true
        }

        expect(ctrl.canCreateProject()).to.be.false

    it 'check if the user can create a public projects', () ->
        mocks.currentUserService.canCreatePublicProjects = sinon.stub().returns({valid: true})

        ctrl = controller "DuplicateProjectCtrl"
        ctrl.limitMembersPublicProject = {valid: true}

        ctrl.projectForm = {
            is_private: false
        }

        expect(ctrl.canCreateProject()).to.be.true

        mocks.currentUserService.canCreatePublicProjects = sinon.stub().returns({valid: false})

        ctrl = controller "DuplicateProjectCtrl"

        ctrl.projectForm = {
            is_private: false
        }

        expect(ctrl.canCreateProject()).to.be.false
