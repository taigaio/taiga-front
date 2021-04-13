describe "ContactProjectButton", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgLightboxFactory()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "Launch Contact Form", () ->
        ctrl = controller("ContactProjectButtonCtrl")
        ctrl.launchContactForm()
        expect(mocks.tgLightboxFactory.create).have.been.called
