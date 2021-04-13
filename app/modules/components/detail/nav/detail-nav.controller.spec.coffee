describe "DetailNavComponent", ->
    DetailNavCtrl =  null
    provide = null
    controller = null
    rootScope = null
    mocks = {}

    _mockTgNav = () ->
        mocks.navUrls = {
            resolve: sinon.stub().returns('project-issues-detail')
            update: () ->
        }

        provide.value "$tgNavUrls", mocks.navUrls

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgNav()
            return null

    beforeEach ->
        module "taigaBase"

        _mocks()

        inject ($controller) ->
            controller = $controller

            DetailNavCtrl = controller "DetailNavCtrl", {}, {
                item: {
                    neighbors: { previous: { ref: 42 } }
                    project_extra_info: { slug: 'example_subject' }
                }
            }

    it "previous item neighbor", () ->
        DetailNavCtrl._checkNav()
        DetailNavCtrl.previousUrl = mocks.navUrls.resolve("project-issues-detail")
        expect(DetailNavCtrl.previousUrl).to.be.equal("project-issues-detail")
