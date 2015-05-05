describe "homeDirective", () ->
    scope = compile = provide = null
    mockTgHomeService = null
    template = "<div ng-controller='HomePage' tg-home></div>"

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgHomeService = () ->
        mockTgHomeService = {
            workInProgress: Immutable.fromJS({
                assignedTo: {
                    userStories: [{"id": 1}]
                    tasks: []
                    issues: []
                }
                watching: {
                    userStories: []
                    tasks: []
                    issues: []
                }
            })
        }

        provide.value "tgHomeService", mockTgHomeService

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgHomeService()
            return null

    beforeEach ->
        module "taigaHome"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "home directive content", () ->
        elm = createDirective()
        console.log 111, elm, elm.find('div')
