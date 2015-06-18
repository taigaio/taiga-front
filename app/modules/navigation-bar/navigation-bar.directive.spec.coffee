describe "navigationBarDirective", () ->
    scope = compile = provide = null
    mocks = {}
    template = "<div tg-navigation-bar></div>"
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

    _mocksCurrentUserService = () ->
        mocks.currentUserService = {
            projects: projects
            isAuthenticated: sinon.stub()
        }

        provide.value "tgCurrentUserService", mocks.currentUserService


    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mockTgDropdownProjectListDirective = () ->
        provide.factory 'tgDropdownProjectListDirective', () -> {}

    _mockTgDropdownUserDirective = () ->
        provide.factory 'tgDropdownUserDirective', () -> {}

    _mocks = () ->
        module ($provide) ->
            provide = $provide

            _mocksCurrentUserService()
            _mockTranslateFilter()
            _mockTgDropdownProjectListDirective()
            _mockTgDropdownUserDirective()
            return null

    beforeEach ->
        module "templates"
        module "taigaNavigationBar"

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

    it "navigation bar directive scope content", () ->
        elm = createDirective()
        scope.$apply()
        expect(elm.isolateScope().vm.projects.size).to.be.equal(3)

        mocks.currentUserService.isAuthenticated.returns(true)

        expect(elm.isolateScope().vm.isAuthenticated).to.be.true
