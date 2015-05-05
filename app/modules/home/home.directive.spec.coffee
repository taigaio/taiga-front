describe "homeDirective", () ->
    scope = compile = provide = null
    template = "<div tg-home></div>"

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgHomeService = () ->
        mockTgHomeService = {
            workInProgress: Immutable.fromJS({
                assignedTo: {
                    userStories: [{"id": 1}]
                    tasks: [{"id": 2}]
                    issues: [{"id": 3}]
                }
                watching: {
                    userStories: [{"id": 4}]
                    tasks: [{"id": 5}]
                    issues: [{"id": 6}]
                }
            })
        }

        provide.value "tgHomeService", mockTgHomeService

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mockTgDuty = () ->
        provide.factory 'tgDutyDirective', () -> {}

    _mockHomeProjectList = () ->
        provide.factory 'tgHomeProjectListDirective', () -> {}

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgDuty()
            _mockHomeProjectList()
            _mockTgHomeService()
            _mockTranslateFilter()
            return null

    beforeEach ->
        module "templates"
        module "taigaHome"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "home directive content", () ->
        elm = createDirective()
        scope.$apply()
        expect(elm.isolateScope().vm.assignedTo.size).to.be.equal(3)
        expect(elm.isolateScope().vm.watching.size).to.be.equal(3)
