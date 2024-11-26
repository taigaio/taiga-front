###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
