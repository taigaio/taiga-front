###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "ExternalAppController", ->
    provide = null
    $controller = null
    $rootScope = null
    mocks = {}

    _inject = (callback) ->
        inject (_$controller_, _$rootScope_) ->
            $rootScope = _$rootScope_
            $controller = _$controller_

    _mockRouteParams = () ->
        mocks.routeParams = {}
        provide.value "$routeParams", mocks.routeParams

    _mockTgExternalAppsService = () ->
        mocks.tgExternalAppsService = {
            getApplicationToken: sinon.stub()
            authorizeApplicationToken: sinon.stub()
        }
        provide.value  "tgExternalAppsService", mocks.tgExternalAppsService

    _mockWindow = () ->
        mocks.window = {
            open: sinon.stub()
            history: {
                back: sinon.stub()
            }
        }
        provide.value "$window", mocks.window

    _mockTgCurrentUserService = () ->
        mocks.tgCurrentUserService = {
            getUser: sinon.stub()
        }
        provide.value  "tgCurrentUserService", mocks.tgCurrentUserService

    _mockLocation = () ->
        mocks.location = {
            url: sinon.stub()
        }
        provide.value "$location", mocks.location

    _mockTgNavUrls = () ->
        mocks.tgNavUrls = {
            resolve: sinon.stub()
        }
        provide.value "$tgNavUrls", mocks.tgNavUrls

    _mockTgXhrErrorService = () ->
        mocks.tgXhrErrorService = {
            response: sinon.spy(),
            notFound: sinon.spy()
        }
        provide.value  "tgXhrErrorService", mocks.tgXhrErrorService

    _mockTgLoader = () ->
        mocks.tgLoader = {
            start: sinon.stub(),
            pageLoaded: sinon.stub()
        }
        provide.value  "tgLoader", mocks.tgLoader

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockRouteParams()
            _mockTgExternalAppsService()
            _mockWindow()
            _mockTgCurrentUserService()
            _mockLocation()
            _mockTgNavUrls()
            _mockTgXhrErrorService()
            _mockTgLoader()
            return null

    beforeEach ->
        module "taigaExternalApps"
        _mocks()
        _inject()

    it "not existing application", (done) ->
        $scope = $rootScope.$new()

        mocks.routeParams.application = 6
        mocks.routeParams.state = "testing-state"

        error = new Error('404')

        mocks.tgExternalAppsService.getApplicationToken.withArgs(mocks.routeParams.application, mocks.routeParams.state).promise().reject(error)

        ctrl = $controller("ExternalApp")

        setTimeout ( ->
            expect(mocks.tgLoader.start.withArgs(false)).to.be.calledOnce
            expect(mocks.tgXhrErrorService.response.withArgs(error)).to.be.calledOnce
            done()
        )

    it "existing application and existing token, automatically redirecting to next url", (done) ->
        $scope = $rootScope.$new()

        mocks.routeParams.application = 6
        mocks.routeParams.state = "testing-state"

        applicationToken = Immutable.fromJS({
            auth_code: "testing-auth-code"
            next_url: "http://next.url"
        })

        mocks.tgExternalAppsService.getApplicationToken.withArgs(mocks.routeParams.application, mocks.routeParams.state).promise().resolve(applicationToken)

        ctrl = $controller("ExternalApp")

        setTimeout ( ->
            expect(mocks.tgLoader.start.withArgs(false)).to.be.calledOnce
            expect(mocks.window.open.callCount).to.be.equal(1)
            expect(mocks.window.open.calledWith("http://next.url")).to.be.true
            done()
        )

    it "existing application and creating new token", (done) ->
        $scope = $rootScope.$new()

        mocks.routeParams.application = 6
        mocks.routeParams.state = "testing-state"

        applicationToken = Immutable.fromJS({})
        mocks.tgExternalAppsService.getApplicationToken.withArgs(mocks.routeParams.application, mocks.routeParams.state).promise().resolve(applicationToken)

        ctrl = $controller("ExternalApp")

        applicationToken = Immutable.fromJS({
            next_url: "http://next.url"
            auth_code: "testing-auth-code"
        })

        mocks.tgExternalAppsService.authorizeApplicationToken.withArgs(mocks.routeParams.application, mocks.routeParams.state).promise().resolve(applicationToken)

        ctrl.createApplicationToken()

        setTimeout ( ->
            expect(mocks.tgLoader.start.withArgs(false)).to.be.calledOnce
            expect(mocks.tgLoader.pageLoaded).to.be.calledOnce
            expect(mocks.window.open.callCount).to.be.equal(1)
            expect(mocks.window.open.calledWith("http://next.url")).to.be.true
            done()
        )

    it "cancel back to previous url", () ->
        $scope = $rootScope.$new()

        mocks.routeParams.application = 6
        mocks.routeParams.state = "testing-state"

        applicationToken = Immutable.fromJS({})
        mocks.tgExternalAppsService.getApplicationToken.withArgs(mocks.routeParams.application, mocks.routeParams.state).promise().resolve(applicationToken)

        ctrl = $controller("ExternalApp")
        expect(mocks.window.history.back.callCount).to.be.equal(0)
        ctrl.cancel()
        expect(mocks.window.history.back.callCount).to.be.equal(1)
