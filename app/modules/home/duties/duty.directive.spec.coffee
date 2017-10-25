###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
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
# File: duty.directive.spec.coffee
###

describe "dutyDirective", () ->
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

    _mockTranslateFilter = () ->
        mockTranslateFilter = (value) ->
            return value
        provide.value "translateFilter", mockTranslateFilter

    _mockEmojifyFilter = () ->
        mockEmojifyFilter = (value) ->
            return value
        provide.value "emojifyFilter", mockEmojifyFilter

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
            _mockTranslateFilter()
            _mockEmojifyFilter()
            return null

    beforeEach ->
        module "templates"
        module "taigaHome"

        _mocks()

        inject ($rootScope, $compile) ->
            scope = $rootScope.$new()
            compile = $compile

    it "duty directive scope content", () ->
        scope.duty = Immutable.fromJS({
            project: 1
            ref: 1
            _name: "userstories"
            assigned_to_extra_info: {
                photo: "http://jstesting.taiga.io/photo"
                full_name_display: "Taiga testing js"
            }
        })

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
