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
# File: projects/transfer/transfer-project.controller.spec.coffee
###

describe "TransferProject", ->
    $controller = null
    $q = null
    provide = null
    $rootScope = null
    mocks = {}

    _mockRouteParams = () ->
        mocks.routeParams = {}
        provide.value "$routeParams", mocks.routeParams

    _mockErrorHandlingService = () ->
        mocks.errorHandlingService = {
            notfound: sinon.stub()
        }

        provide.value "tgErrorHandlingService", mocks.errorHandlingService

    _mockProjectsService = () ->
        mocks.projectsService = {
            transferValidateToken: sinon.stub()
            transferAccept: sinon.stub()
            transferReject: sinon.stub()
        }

        provide.value "tgProjectsService", mocks.projectsService

    _mockLocation = () ->
        mocks.location = {
            path: sinon.stub()
        }
        provide.value "$location", mocks.location

    _mockAuth = () ->
        mocks.auth = {
            refresh: sinon.stub()
        }

        provide.value "$tgAuth", mocks.auth

    _mockCurrentUserService = () ->
        mocks.currentUserService = {
            getUser: sinon.stub()
            canOwnProject: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mockTgNavUrls = () ->
        mocks.tgNavUrls = {
            resolve: sinon.stub()
        }

        provide.value "$tgNavUrls", mocks.tgNavUrls

    _mockTranslate = () ->
        mocks.translate = {
            instant: sinon.stub()
        }

        provide.value "$translate", mocks.translate

    _mockTgConfirm = ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value("$tgConfirm", mocks.tgConfirm)

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockRouteParams()
            _mockProjectsService()
            _mockLocation()
            _mockAuth()
            _mockCurrentUserService()
            _mockTgNavUrls()
            _mockTranslate()
            _mockTgConfirm()
            _mockErrorHandlingService()
            return null

    _inject = (callback) ->
        inject (_$controller_, _$q_, _$rootScope_) ->
            $q = _$q_
            $rootScope = _$rootScope_
            $controller = _$controller_

    beforeEach ->
        module "taigaProjects"
        _mocks()
        _inject()

    it "invalid token", (done) ->
        project = Immutable.fromJS({
            id: 1
        })

        user = Immutable.fromJS({})

        mocks.auth.refresh.promise().resolve()
        mocks.routeParams.token = "BAD_TOKEN"
        mocks.currentUserService.getUser.returns(user)
        mocks.projectsService.transferValidateToken.withArgs(1, "BAD_TOKEN").promise().reject(new Error('error'))
        mocks.tgNavUrls.resolve.withArgs("not-found").returns("/not-found")

        ctrl = $controller("TransferProjectController")
        ctrl.project = project
        ctrl.initialize().then () ->
            expect(mocks.errorHandlingService.notfound).have.been.called
            done()

    it "valid token private project with max projects for user", (done) ->
        project = Immutable.fromJS({
            id: 1
            is_private: true
        })

        user = Immutable.fromJS({
            max_private_projects: 1
            total_private_projects: 1
            max_memberships_private_projects: 25
        })

        mocks.auth.refresh.promise().resolve()
        mocks.routeParams.token = "TOKEN"
        mocks.currentUserService.getUser.returns(user)
        mocks.projectsService.transferValidateToken.withArgs(1, "TOKEN").promise().resolve()

        ctrl = $controller("TransferProjectController")
        ctrl.project = project
        ctrl.initialize().then () ->
            expect(ctrl.ownerMessage).to.be.equal("ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PRIVATE")
            expect(ctrl.maxProjects).to.be.equal(1)
            expect(ctrl.currentProjects).to.be.equal(1)
            done()

      it "valid token private project without max projects for user", (done) ->
          project = Immutable.fromJS({
              id: 1
              is_private: true
          })

          user = Immutable.fromJS({
              max_private_projects: null
              total_private_projects: 1
              max_memberships_private_projects: 25
          })

          mocks.auth.refresh.promise().resolve()
          mocks.routeParams.token = "TOKEN"
          mocks.currentUserService.getUser.returns(user)
          mocks.projectsService.transferValidateToken.withArgs(1, "TOKEN").promise().resolve()
          mocks.translate.instant.withArgs("ADMIN.PROJECT_TRANSFER.UNLIMITED_PROJECTS").returns("UNLIMITED_PROJECTS")

          ctrl = $controller("TransferProjectController")
          ctrl.project = project
          ctrl.initialize().then () ->
              expect(ctrl.ownerMessage).to.be.equal("ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PRIVATE")
              expect(ctrl.maxProjects).to.be.equal("UNLIMITED_PROJECTS")
              expect(ctrl.currentProjects).to.be.equal(1)
              done()

    it "valid token public project with max projects for user", (done) ->
        project = Immutable.fromJS({
            id: 1
            is_public: true
        })

        user = Immutable.fromJS({
            max_public_projects: 1
            total_public_projects: 1
            max_memberships_public_projects: 25
        })

        mocks.auth.refresh.promise().resolve()
        mocks.routeParams.token = "TOKEN"
        mocks.currentUserService.getUser.returns(user)
        mocks.projectsService.transferValidateToken.withArgs(1, "TOKEN").promise().resolve()

        ctrl = $controller("TransferProjectController")
        ctrl.project = project
        ctrl.initialize().then () ->
            expect(ctrl.ownerMessage).to.be.equal("ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PUBLIC")
            expect(ctrl.maxProjects).to.be.equal(1)
            expect(ctrl.currentProjects).to.be.equal(1)
            done()

      it "valid token public project without max projects for user", (done) ->
          project = Immutable.fromJS({
              id: 1
              is_public: true
          })

          user = Immutable.fromJS({
              max_public_projects: null
              total_public_projects: 1
              max_memberships_public_projects: 25
          })

          mocks.auth.refresh.promise().resolve()
          mocks.routeParams.token = "TOKEN"
          mocks.currentUserService.getUser.returns(user)
          mocks.projectsService.transferValidateToken.withArgs(1, "TOKEN").promise().resolve()
          mocks.translate.instant.withArgs("ADMIN.PROJECT_TRANSFER.UNLIMITED_PROJECTS").returns("UNLIMITED_PROJECTS")

          ctrl = $controller("TransferProjectController")
          ctrl.project = project
          ctrl.initialize().then () ->
              expect(ctrl.ownerMessage).to.be.equal("ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PUBLIC")
              expect(ctrl.maxProjects).to.be.equal("UNLIMITED_PROJECTS")
              expect(ctrl.currentProjects).to.be.equal(1)
              done()

      it "transfer accept", (done) ->
          project = Immutable.fromJS({
              id: 1
              slug: "slug"
          })

          user = Immutable.fromJS({})

          mocks.auth.refresh.promise().resolve()
          mocks.routeParams.token = "TOKEN"
          mocks.currentUserService.getUser.returns(user)
          mocks.projectsService.transferValidateToken.withArgs(1, "TOKEN").promise().resolve()
          mocks.projectsService.transferAccept.withArgs(1, "TOKEN", "this is my reason").promise().resolve()
          mocks.tgNavUrls.resolve.withArgs("project-admin-project-profile-details", {project: "slug"}).returns("/project/slug/")
          mocks.translate.instant.withArgs("ADMIN.PROJECT_TRANSFER.ACCEPTED_PROJECT_OWNERNSHIP").returns("ACCEPTED_PROJECT_OWNERNSHIP")

          ctrl = $controller("TransferProjectController")
          ctrl.project = project
          ctrl.initialize().then () ->
              ctrl.transferAccept("TOKEN", "this is my reason").then ->
                  expect(mocks.location.path).to.be.calledWith("/project/slug/")
                  expect(mocks.tgConfirm.notify).to.be.calledWith("success", "ACCEPTED_PROJECT_OWNERNSHIP", '', 5000)

                  done()

      it "transfer reject", (done) ->
          project = Immutable.fromJS({
              id: 1
              slug: "slug"
          })

          user = Immutable.fromJS({})

          mocks.auth.refresh.promise().resolve()
          mocks.routeParams.token = "TOKEN"
          mocks.currentUserService.getUser.returns(user)
          mocks.projectsService.transferValidateToken.withArgs(1, "TOKEN").promise().resolve()
          mocks.projectsService.transferReject.withArgs(1, "TOKEN", "this is my reason").promise().resolve()
          mocks.tgNavUrls.resolve.withArgs("home", {project: "slug"}).returns("/project/slug/")
          mocks.translate.instant.withArgs("ADMIN.PROJECT_TRANSFER.REJECTED_PROJECT_OWNERNSHIP").returns("REJECTED_PROJECT_OWNERNSHIP")

          ctrl = $controller("TransferProjectController")
          ctrl.project = project
          ctrl.initialize().then () ->
              ctrl.transferReject("TOKEN", "this is my reason").then ->
                  expect(mocks.location.path).to.be.calledWith("/project/slug/")
                  expect(mocks.tgConfirm.notify).to.be.calledWith("success", "REJECTED_PROJECT_OWNERNSHIP", '', 5000)

                  done()
