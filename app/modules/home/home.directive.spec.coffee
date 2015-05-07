describe "homeDirective", () ->
    scope = compile = provide = timeout = null
    mockTgHomeService = mockTgProjectsService = null
    thenStubGetCurrentUserProjectsById = thenStubGetWorkInProgress = null
    template = "<div tg-home></div>"

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgHomeService = () ->
        thenStubGetWorkInProgress = sinon.stub()

        mockTgHomeService = {
            getWorkInProgress: sinon.stub()
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
            attachProjectInfoToWorkInProgress: sinon.stub()
        }

        mockTgHomeService.getWorkInProgress.returns({
            then: thenStubGetWorkInProgress
        })
        provide.value "tgHomeService", mockTgHomeService

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mockTgDuty = () ->
        provide.factory 'tgDutyDirective', () -> {}

    _mockHomeProjectList = () ->
        provide.factory 'tgHomeProjectListDirective', () -> {}

    _mockTgProjectsService = () ->
        thenStubGetCurrentUserProjectsById = sinon.stub()
        mockTgProjectsService = {
            getCurrentUserProjects: sinon.stub()
            currentUserProjectsById: {
                get: sinon.stub()
            }
        }

        mockTgProjectsService.getCurrentUserProjects.returns({
            then: thenStubGetCurrentUserProjectsById
        })
        provide.value "tgProjectsService", mockTgProjectsService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgDuty()
            _mockHomeProjectList()
            _mockTgHomeService()
            _mockTranslateFilter()
            _mockTgProjectsService()
            return null

    beforeEach ->
        module "templates"
        module "taigaHome"

        _mocks()

        inject ($rootScope, $compile, $timeout) ->
            scope = $rootScope.$new()
            compile = $compile
            timeout = $timeout

    it "home directive content", () ->
        elm = createDirective()
        scope.$apply()

        thenStubGetCurrentUserProjectsById.callArg(0)
        thenStubGetWorkInProgress.callArg(0)
        timeout.flush()

        expect(elm.isolateScope().vm.assignedTo.size).to.be.equal(3)
        expect(elm.isolateScope().vm.watching.size).to.be.equal(3)
