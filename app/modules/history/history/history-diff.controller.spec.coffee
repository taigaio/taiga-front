describe "ActivitiesDiffController", ->
    provide = null
    controller = null
    mocks = {}

    beforeEach ->
        module "taigaHistory"

        inject ($controller) ->
            controller = $controller

    it "Check diff between tags", () ->
        activitiesDiffCtrl = controller "ActivitiesDiffCtrl"

        activitiesDiffCtrl.type = "tags"

        activitiesDiffCtrl.diff = [
            ["architecto", "perspiciatis", "testafo"],
            ["architecto", "perspiciatis", "testafo", "fasto"]
        ]

        activitiesDiffCtrl.diffTags()
        expect(activitiesDiffCtrl.diffRemoveTags).to.be.equal('')
        expect(activitiesDiffCtrl.diffAddTags).to.be.equal('fasto')
