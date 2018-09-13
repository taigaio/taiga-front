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
# File: projects/create/import/import-project.service.spec.coffee
###

describe "tgImportProjectService", ->
    $provide = null
    importProjectService = null
    mocks = {}

    _mockCurrentUserService = ->
        mocks.currentUserService = {
            loadProjects: sinon.stub(),
            getUser: sinon.stub(),
            canCreatePrivateProjects: sinon.stub(),
            canCreatePublicProjects: sinon.stub()
        }

        $provide.value("tgCurrentUserService", mocks.currentUserService)

    _mockAuth = ->
        mocks.auth = {
            refresh: sinon.stub()
        }

        $provide.value("$tgAuth", mocks.auth)

    _mockLightboxFactory = ->
        mocks.lightboxFactory = {
            create: sinon.stub()
        }

        $provide.value("tgLightboxFactory", mocks.lightboxFactory)

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }

        $provide.value("$translate", mocks.translate)

    _mockConfirm = ->
        mocks.confirm = {
            success: sinon.stub(),
            notify: sinon.stub()
        }

        $provide.value("$tgConfirm", mocks.confirm)

    _mockLocation = ->
        mocks.location = {
            path: sinon.stub()
        }

        $provide.value("$location", mocks.location)

    _mockNavUrls = ->
        mocks.navUrls = {
            resolve: sinon.stub()
        }

        $provide.value("$tgNavUrls", mocks.navUrls)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockCurrentUserService()
            _mockAuth()
            _mockLightboxFactory()
            _mockTranslate()
            _mockConfirm()
            _mockLocation()
            _mockNavUrls()

            return null

    _inject = ->
        inject (_tgImportProjectService_) ->
            importProjectService = _tgImportProjectService_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "import success async mode", (done) ->
        result = {
            status: 202,
            data: {
                slug: 'project-slug'
            }
        }

        mocks.translate.instant.returns('xxx')

        mocks.currentUserService.loadProjects.promise().resolve()

        importProjectService.importSuccess(result).then () ->
            expect(mocks.confirm.success).have.been.calledOnce
            done()

    it "import success sync mode", (done) ->
        result = {
            status: 201,
            data: {
                slug: 'project-slug'
            }
        }

        mocks.translate.instant.returns('msg')

        mocks.navUrls.resolve.withArgs('project-admin-project-profile-details', {project: 'project-slug'}).returns('url')

        mocks.currentUserService.loadProjects.promise().resolve()

        importProjectService.importSuccess(result).then () ->
            expect(mocks.location.path).have.been.calledWith('url')
            expect(mocks.confirm.notify).have.been.calledWith('success', 'msg')
            done()

    it "private get restriction errors, private & member error", () ->
        result = {
            headers: {
                isPrivate: true,
                memberships: 10
            }
        }

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            max_memberships_private_projects: 1
        }))

        mocks.currentUserService.canCreatePrivateProjects.returns({
            valid: false
        })

        error = importProjectService.getRestrictionError(result)

        expect(error).to.be.eql({
            key: 'private-space-members',
            values: {
                max_memberships: 1,
                members: 10
            }
        })

    it "private get restriction errors, private limit error", () ->
        result = {
            headers: {
                isPrivate: true,
                memberships: 10
            }
        }

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            max_memberships_private_projects: 20
        }))

        mocks.currentUserService.canCreatePrivateProjects.returns({
            valid: false
        })

        error = importProjectService.getRestrictionError(result)

        expect(error).to.be.eql({
            key: 'private-space',
            values: {
                max_memberships: null,
                members: 10
            }
        })

    it "private get restriction errors, members error", () ->
        result = {
            headers: {
                isPrivate: true,
                memberships: 10
            }
        }

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            max_memberships_private_projects: 1
        }))

        mocks.currentUserService.canCreatePrivateProjects.returns({
            valid: true
        })

        error = importProjectService.getRestrictionError(result)

        expect(error).to.be.eql({
            key: 'private-members',
            values: {
                max_memberships: 1,
                members: 10
            }
        })

    it "public get restriction errors, public & member error", () ->
        result = {
            headers: {
                isPrivate: false,
                memberships: 10
            }
        }

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            max_memberships_public_projects: 1
        }))

        mocks.currentUserService.canCreatePublicProjects.returns({
            valid: false
        })

        error = importProjectService.getRestrictionError(result)

        expect(error).to.be.eql({
            key: 'public-space-members',
            values: {
                max_memberships: 1,
                members: 10
            }
        })

    it "public get restriction errors, public limit error", () ->
        result = {
            headers: {
                isPrivate: false,
                memberships: 10
            }
        }

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            max_memberships_public_projects: 20
        }))

        mocks.currentUserService.canCreatePublicProjects.returns({
            valid: false
        })

        error = importProjectService.getRestrictionError(result)

        expect(error).to.be.eql({
            key: 'public-space',
            values: {
                max_memberships: null,
                members: 10
            }
        })

    it "public get restriction errors, members error", () ->
        result = {
            headers: {
                isPrivate: false,
                memberships: 10
            }
        }

        mocks.currentUserService.getUser.returns(Immutable.fromJS({
            max_memberships_public_projects: 1
        }))

        mocks.currentUserService.canCreatePublicProjects.returns({
            valid: true
        })

        error = importProjectService.getRestrictionError(result)

        expect(error).to.be.eql({
            key: 'public-members',
            values: {
                max_memberships: 1,
                members: 10
            }
        })
