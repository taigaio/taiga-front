describe "tgXhrErrorService", ->
    xhrErrorService = provide = null
    mocks = {}

    _mockQ = () ->
        mocks.q = {
            reject: sinon.spy()
        }

        provide.value "$q", mocks.q


    _mockErrorHandling = () ->
        mocks.errorHandling = {
            notfound: sinon.stub(),
            permissionDenied: sinon.stub()
        }

        provide.value "tgErrorHandlingService", mocks.errorHandling

    _inject = (callback) ->
        inject (_tgXhrErrorService_) ->
            xhrErrorService = _tgXhrErrorService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockQ()
            _mockErrorHandling()

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

        xhrErrorService.response(xhr)

        expect(mocks.q.reject.withArgs(xhr)).to.be.calledOnce
        expect(mocks.errorHandling.notfound).to.be.calledOnce

    it "403 status redirect to permission-denied page", () ->
        xhr = {
            status: 403
        }

        xhrErrorService.response(xhr)

        expect(mocks.q.reject.withArgs(xhr)).to.be.calledOnce
        expect(mocks.errorHandling.permissionDenied).to.be.calledOnce
