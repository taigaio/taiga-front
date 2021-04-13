describe "ProfileTabsController", ->
    myCtrl = scope = null

    beforeEach ->
        module "taigaProfile"

        inject ($controller) ->
            scope = {}
            myCtrl = $controller "ProfileTabs",
                $scope: scope

    it "tabs should be an array", () ->
        expect(myCtrl.tabs).is.an("array")

    it "add new tab", () ->
        tab = {"fakeTab": true}

        myCtrl.addTab(tab)

        expect(myCtrl.tabs[0]).to.be.eql(tab)

    it "toggleTab, mark the tab passed as parameter to active", () ->
        fakeTabs = [
            {id: 1},
            {id: 2},
            {id: 3}
        ]

        myCtrl.tabs = fakeTabs

        myCtrl.toggleTab(fakeTabs[1])

        expect(myCtrl.tabs[0].active).to.be.false
        expect(myCtrl.tabs[1].active).to.be.true
        expect(myCtrl.tabs[2].active).to.be.false

        myCtrl.toggleTab(fakeTabs[0])

        expect(myCtrl.tabs[0].active).to.be.true
        expect(myCtrl.tabs[1].active).to.be.false
        expect(myCtrl.tabs[2].active).to.be.false
