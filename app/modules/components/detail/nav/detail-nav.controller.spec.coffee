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
# File: components/detail/header/detail-header.controller.spec.coffee
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
