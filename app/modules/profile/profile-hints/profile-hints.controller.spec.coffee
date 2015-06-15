describe "ProfileHints", ->
    $controller = null
    $provide = null

    mocks = {}

    _mockTranslate = () ->
        mocks.translateService = sinon.stub()

        $provide.value "$translate", mocks.translateService

    _mocks = () ->
        module (_$provide_) ->
            $provide = _$provide_
            _mockTranslate()

            return null

    beforeEach ->
        module "taigaProfile"
        _mocks()

        inject (_$controller_) ->
            $controller = _$controller_

    it "random hint generator", (done) ->
        mocks.translateService.promise().resolve("fill")

        ctrl = $controller("ProfileHints")

        setTimeout ( ->
                expect(ctrl.hint.title).to.be.equal("fill")
                expect(ctrl.hint.text).to.be.equal("fill")
                expect(ctrl.hint.linkText).to.have.length.above(1)
                done()
        )
