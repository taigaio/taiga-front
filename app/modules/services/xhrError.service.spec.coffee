describe "tgXhrErrorService", ->
    xhrErrorService = provide = null
    mocks = {}

    _mockQ = () ->
        mocks.q = {
            reject: sinon.spy()
        }

        provide.value "$q", mocks.q

    _mockLocation = () ->
        mocks.location = {
            path: sinon.spy(),
            replace: sinon.spy()
        }

        provide.value "$location", mocks.location

    _mockNavUrls = () ->
        mocks.navUrls = {
            resolve: sinon.stub()
        }

        provide.value "$tgNavUrls", mocks.navUrls

    _inject = (callback) ->
        inject (_tgXhrErrorService_) ->
            xhrErrorService = _tgXhrErrorService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockQ()
            _mockLocation()
            _mockNavUrls()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    it "404 status redirect to not-found page", () ->
        xhr = {
            status: 404
        }

        mocks.navUrls.resolve.withArgs("not-found").returns("not-found")

        xhrErrorService.response(xhr)

        expect(mocks.q.reject.withArgs(xhr)).to.be.calledOnce
        expect(mocks.location.path.withArgs("not-found")).to.be.calledOnce
        expect(mocks.location.replace).to.be.calledOnce

    it "403 status redirect to permission-denied page", () ->
        xhr = {
            status: 403
        }

        mocks.navUrls.resolve.withArgs("permission-denied").returns("permission-denied")

        xhrErrorService.response(xhr)

        expect(mocks.q.reject.withArgs(xhr)).to.be.calledOnce
        expect(mocks.location.path.withArgs("permission-denied")).to.be.calledOnce
        expect(mocks.location.replace).to.be.calledOnce
