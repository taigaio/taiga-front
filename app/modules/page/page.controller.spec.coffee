describe "PageController", ->
    pageCtrl =  null
    provide = null
    controller = null
    mocks = {}

    _mockPageParams = () ->
        mocks.pageParams = {}

        provide.value "pageParams", mocks.pageParams

    _mockAppTitle = () ->
        mocks.appTitle = {
            set: sinon.spy()
        }

        provide.value "$appTitle", mocks.appTitle

    _mockTranslate = () ->
        mocks.translate = sinon.stub()

        provide.value "$translate", mocks.translate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockAppTitle()
            _mockPageParams()
            _mockTranslate()

            return null

    beforeEach ->
        module "taigaPage"

        _mocks()

        inject ($controller) ->
            controller = $controller

    describe "page title", () ->
        it "if title is defined set it", () ->
            thenStub = sinon.stub()

            mocks.pageParams.title = "TITLE"
            mocks.translate.withArgs("TITLE").returns({
                then: thenStub
            })

            pageCtrl = controller "Page",
                $scope: {}

            thenStub.callArg(0, "TITLE")

            expect(mocks.appTitle.set.withArgs("TITLE")).have.been.calledOnce

        it "if title is not defined not call appTitle", () ->
            pageCtrl = controller "Page",
                $scope: {}

            expect(mocks.translate).have.callCount(0)
            expect(mocks.appTitle.set.withArgs("TITLE")).have.callCount(0)
