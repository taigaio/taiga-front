###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: profile/profile-tabs/profile-tabs.controller.spec.coffee
###

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
