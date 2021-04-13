describe "CommentsController", ->
    provide = null
    controller = null
    mocks = {}

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            return null

    beforeEach ->
        module "taigaHistory"
        _mocks()

        inject ($controller) ->
            controller = $controller

    it "set can add comment permission", () ->
        commentsCtrl = controller "CommentsCtrl"
        commentsCtrl.name = "us"
        commentsCtrl.initializePermissions()
        expect(commentsCtrl.canAddCommentPermission).to.be.equal("comment_us")
