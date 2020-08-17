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
# File: navigation-bar/dropdown-user/dropdown-user.directive.spec.coffee
###

describe "dropdownUserDirective", () ->
    scope = compile = provide = null
    mockTgAuth = null
    mockTgConfig = null
    mockTgLocation = null
    mockTgNavUrls = null
    mockTgFeedbackService = null
    template = "<div tg-dropdown-user></div>"

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mockTgAuth = () ->
        mockTgAuth = {
            userData: Immutable.fromJS({id: 66})
            logout: sinon.stub()
        }
        provide.value "$tgAuth", mockTgAuth

    _mockTgConfig = () ->
        mockTgConfig = {
            get: sinon.stub()
        }
        provide.value "$tgConfig", mockTgConfig

    _mockTgLocation = () ->
        mockTgLocation = {
            url: sinon.stub()
            search: sinon.stub()
        }

        provide.value "$tgLocation", mockTgLocation

    _mockTgNavUrls = () ->
        mockTgNavUrls = {
            resolve: sinon.stub()
        }
        provide.value "$tgNavUrls", mockTgNavUrls

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTranslateFilter()
            _mockTgAuth()
            _mockTgConfig()
            _mockTgLocation()
            _mockTgNavUrls()
            return null

    beforeEach ->
        module "templates"
        module "taigaNavigationBar"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "dropdown user directive scope content", () ->
        mockTgConfig.get.withArgs("feedbackEnabled").returns(true)
        elm = createDirective()
        scope.$apply()

        vm = elm.isolateScope().vm
        expect(vm.user.get("id")).to.be.equal(66)
        expect(vm.isFeedbackEnabled).to.be.equal(true)

    it "dropdown user log out", () ->
        mockTgNavUrls.resolve.withArgs("discover").returns("/discover")
        elm = createDirective()
        scope.$apply()
        vm = elm.isolateScope().vm
        expect(mockTgAuth.logout.callCount).to.be.equal(0)
        expect(mockTgLocation.url.callCount).to.be.equal(0)
        expect(mockTgLocation.search.callCount).to.be.equal(0)
        vm.logout()
        expect(mockTgAuth.logout.callCount).to.be.equal(1)
        expect(mockTgLocation.url.callCount).to.be.equal(1)
        expect(mockTgLocation.search.callCount).to.be.equal(1)
        expect(mockTgLocation.url.calledWith("/discover")).to.be.true
        expect(mockTgLocation.search.calledWith({})).to.be.true

