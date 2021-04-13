describe "homeProjectListDirective", () ->
    scope = compile = provide = null
    mocks = {}
    template = "<div tg-home-project-list></div>"
    projects = Immutable.fromJS({
        recents: [
            {id: 1},
            {id: 2},
            {id: 3}
        ]
    })

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgCurrentUserService = () ->
        mocks.currentUserService = {
            projects: projects
        }

        provide.value "tgCurrentUserService", mocks.currentUserService

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgCurrentUserService()
            _mockTranslateFilter()
            return null

    beforeEach ->
        module "templates"
        module "taigaHome"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

        recents = Immutable.fromJS([
            {
                id:1
            },
            {
                id: 2
            }
        ])

    it "home project list directive scope content", () ->
        elm = createDirective()
        scope.$apply()
        expect(elm.isolateScope().vm.projects.size).to.be.equal(3)
