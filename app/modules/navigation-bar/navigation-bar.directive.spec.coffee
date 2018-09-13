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
# File: navigation-bar/navigation-bar.directive.spec.coffee
###

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

    _mocksLocationService = () ->
        mocks.locationService = {
            url: sinon.stub()
            search: sinon.stub()
        }

        provide.value "$tgLocation", mocks.locationService

    _mocksConfig = () ->
        mocks.config =  Immutable.fromJS({
            publicRegisterEnabled: true
        })

        provide.value "$tgConfig", mocks.config

    _mockTgNavUrls = () ->
        mocks.navUrls = {
            resolve: sinon.stub()
        }
        provide.value "$tgNavUrls", mocks.navUrls

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
            _mocksLocationService()
            _mockTgNavUrls( )
            _mockTranslateFilter()
            _mockTgDropdownProjectListDirective()
            _mockTgDropdownUserDirective()
            _mocksConfig()

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

    it "navigation bar login", () ->
        mocks.navUrls.resolve.withArgs("login").returns("/login")
        nextUrl = "/discover/search?order_by=-total_activity_last_month"
        mocks.locationService.url.returns(nextUrl)
        elm = createDirective()
        scope.$apply()
        vm = elm.isolateScope().vm
        expect(mocks.locationService.url.callCount).to.be.equal(0)
        expect(mocks.locationService.search.callCount).to.be.equal(0)
        vm.login()
        expect(mocks.locationService.url.callCount).to.be.equal(2)
        expect(mocks.locationService.search.callCount).to.be.equal(1)
        expect(mocks.locationService.url.calledWith("/login")).to.be.true
        expect(mocks.locationService.search.calledWith({next: encodeURIComponent(nextUrl)})).to.be.true
        expect(vm.publicRegisterEnabled).to.be.true
