###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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

    _mockResources = () ->
        mocks.resources = {
            userstories: {
                getQueryParams: sinon.stub().returns({})
                getBacklog: sinon.stub().returns({})
            }
        }

        provide.value "$tgResources", mocks.resources

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgNav()
            _mockResources()
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
