describe "WatchButton", ->
    provide = null
    $controller = null
    $rootScope = null
    mocks = {}

    _mockCurrentUser = () ->
        mocks.currentUser = {
            getUser: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUser

    _mocks = ->
        mocks = {
            onWatch: sinon.stub(),
            onUnwatch: sinon.stub()
        }

        module ($provide) ->
            provide = $provide
            _mockCurrentUser()
            return null

    _inject = (callback) ->
        inject (_$controller_, _$rootScope_) ->
            $rootScope = _$rootScope_
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"
        _setup()

    it "watch", (done) ->
        $scope = $rootScope.$new()

        mocks.onWatch = sinon.stub().promise()

        ctrl = $controller("WatchButton", $scope, {
            item: {is_watcher: false}
            onWatch: mocks.onWatch
            onUnwatch: mocks.onUnwatch
        })


        promise = ctrl.toggleWatch()

        expect(ctrl.loading).to.be.true;

        mocks.onWatch.resolve()

        promise.finally () ->
            expect(mocks.onWatch).to.be.calledOnce
            expect(ctrl.loading).to.be.false;

            done()

    it "unwatch", (done) ->
        $scope = $rootScope.$new()

        mocks.onUnwatch = sinon.stub().promise()

        ctrl = $controller("WatchButton", $scope, {
            item: {is_watcher: true}
            onWatch: mocks.onWatch
            onUnwatch: mocks.onUnwatch
        })

        promise = ctrl.toggleWatch()

        expect(ctrl.loading).to.be.true;

        mocks.onUnwatch.resolve()

        promise.finally () ->
            expect(mocks.onUnwatch).to.be.calledOnce
            expect(ctrl.loading).to.be.false;

            done()
