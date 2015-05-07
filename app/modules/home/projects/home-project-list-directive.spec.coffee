describe "homeProjectListDirective", () ->
    scope = compile = provide = null
    mockTgProjectsService = null
    template = "<div tg-home-project-list></div>"
    recents = []

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgProjectsService = () ->
        mockTgProjectsService = {
            newProject: sinon.stub()
            currentUserProjects: {
                get: sinon.stub()
            }
        }
        provide.value "tgProjectsService", mockTgProjectsService

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgProjectsService()
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
        mockTgProjectsService.currentUserProjects.get
            .withArgs("recents")
            .returns(recents)

        elm = createDirective()
        scope.$apply()
        expect(elm.isolateScope().vm.projects.size).to.be.equal(2)

    it "home project list directive newProject", () ->
        elm = createDirective()
        scope.$apply()
        expect(mockTgProjectsService.newProject.callCount).to.be.equal(0)
        elm.isolateScope().vm.newProject()
        expect(mockTgProjectsService.newProject.callCount).to.be.equal(1)
