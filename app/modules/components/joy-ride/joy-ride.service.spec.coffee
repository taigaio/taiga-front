describe "tgJoyRideService", ->
    joyRideService = provide = null
    mocks = {}

    _mockTranslate = () ->
        mocks.translate = {
            instant: sinon.stub()
        }

        provide.value "$translate", mocks.translate

    _mockCheckPermissionsService = () ->
        mocks.checkPermissionsService = {
            check: sinon.stub()
        }

        mocks.checkPermissionsService.check.returns(true)

        provide.value "tgCheckPermissionsService", mocks.checkPermissionsService

    _inject = (callback) ->
        inject (_tgJoyRideService_) ->
            joyRideService = _tgJoyRideService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTranslate()
            _mockCheckPermissionsService()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaComponents"
        _setup()
        _inject()

    it "get joyride by category", () ->
        example = {
            element: '.project-list > section:not(.ng-hide)',
            position: 'left',
            joyride: {
                title: 'test',
                text: 'test'
            },
            intro: '<h3>test</h3><p>test</p>'
        }

        mocks.translate.instant.returns('test')

        joyRide = joyRideService.get('dashboard')

        expect(joyRide).to.have.length(4)
        expect(joyRide[0]).to.be.eql(example)
