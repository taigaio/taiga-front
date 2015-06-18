describe "PaginateResponseService", ->
    paginateResponseService = null

    _inject = () ->
        inject (_tgPaginateResponseService_) ->
            paginateResponseService = _tgPaginateResponseService_

    beforeEach ->
        module "taigaCommon"
        _inject()

    it "convert angualr pagination response to an object", () ->
        headerMock = sinon.stub()

        headerMock.withArgs("x-pagination-next").returns(true)
        headerMock.withArgs("x-pagination-prev").returns(false)
        headerMock.withArgs("x-pagination-current").returns(5)
        headerMock.withArgs("x-pagination-count").returns(234)

        serverResponse = Immutable.Map({
            data: ['11', '22'],
            headers: headerMock
        })

        result = paginateResponseService(serverResponse)

        result = result.toJS()

        expect(result.data).to.have.length(2)
        expect(result.next).to.be.true
        expect(result.prev).to.be.false
        expect(result.current).to.be.equal(5)
        expect(result.count).to.be.equal(234)
