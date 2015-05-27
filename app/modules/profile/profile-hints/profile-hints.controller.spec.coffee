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

        returned = {
            then: () ->
        }

        mocks.translateService.withArgs("HINTS.HINT1_TITLE").promise().resolve("title_1")
        mocks.translateService.withArgs("HINTS.HINT1_TEXT").promise().resolve("text_1")

        mocks.translateService.withArgs("HINTS.HINT2_TITLE").promise().resolve("title_2")
        mocks.translateService.withArgs("HINTS.HINT2_TEXT").promise().resolve("text_2")

        ctrl = $controller("ProfileHints")

        setTimeout ( ->
            if ctrl.url == "https://taiga.io/support/custom-fields/"
                expect(ctrl.title).to.be.equal("title_2")
                expect(ctrl.text).to.be.equal("text_2")
                done()
            else if ctrl.url == "https://taiga.io/support/import-export-projects/"
                expect(ctrl.title).to.be.equal("title_1")
                expect(ctrl.text).to.be.equal("text_1")
                done()
        )
