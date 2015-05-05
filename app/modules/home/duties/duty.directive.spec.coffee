describe "homeDirective", () ->
    scope = compile = provide = null
    mockTgProjectsService = null
    mockTgNavUrls = null
    mockTranslate = null
    template = "<div tg-duty='duty'></div>"

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgNavUrls = () ->
        mockTgNavUrls = {
            resolve: sinon.stub()
        }
        provide.value "$tgNavUrls", mockTgNavUrls

    _mockTgProjectsService = () ->
        mockTgProjectsService = {
            projectsById: {
                get: sinon.stub()
            }
        }
        provide.value "tgProjectsService", mockTgProjectsService

    _mockTranslate = () ->
        mockTranslate = {
            instant: sinon.stub()
        }
        provide.value "$translate", mockTranslate

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgNavUrls()
            _mockTgProjectsService()
            _mockTranslate()
            return null

    beforeEach ->
        module "templates"
        module "taigaHome"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "duty directive content", () ->
        scope.duty = {
            project: 1
            ref: 1
            _name: "userstories"
            assigned_to_extra_info: {
                photo: "http://jstesting.taiga.io/photo"
                full_name_display: "Taiga testing js"
            }
        }

        mockTgProjectsService.projectsById.get
            .withArgs("1")
            .returns({slug: "project-slug", "name": "testing js project"})

        mockTgNavUrls.resolve
            .withArgs("project-userstories-detail", {project: "project-slug", ref: 1})
            .returns("http://jstesting.taiga.io")

        mockTranslate.instant
            .withArgs("COMMON.USER_STORY")
            .returns("User story translated")

        elm = createDirective()
        scope.$apply()
        expect(elm.isolateScope().vm.getDutyType()).to.be.equal("User story translated")
        expect(elm.isolateScope().vm.getUrl()).to.be.equal("http://jstesting.taiga.io")
        expect(elm.isolateScope().vm.getProjectName()).to.be.equal("testing js project")
