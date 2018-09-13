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
# File: projects/components/contact-project-button/contact-project-button.controller.spec.coffee
###

describe "ContactProjectButton", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {
            create: sinon.stub()
        }

        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgLightboxFactory()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "Launch Contact Form", () ->
        ctrl = controller("ContactProjectButtonCtrl")
        ctrl.launchContactForm()
        expect(mocks.tgLightboxFactory.create).have.been.called
