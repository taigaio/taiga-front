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
# File: projects/components/lb-contact-project/lb-contact-project.controller.spec.coffee
###

describe "LbContactProject", ->
    provide = null
    controller = null
    mocks = {}

    _mockTgLightboxSercice = () ->
        mocks.tglightboxService = {
            closeAll: sinon.stub()
        }

        provide.value "lightboxService", mocks.tglightboxService

    _mockTgResources = () ->
        mocks.tgResources = {
            projects: {
                contactProject: sinon.stub()
            }
        }

        provide.value "tgResources", mocks.tgResources

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTgLightboxSercice()
            _mockTgResources()
            _mockTgConfirm()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()

        inject ($controller) ->
            controller = $controller

    it "Contact Project", (done) ->
        ctrl = controller("ContactProjectLbCtrl")
        ctrl.contact = {
            message: 'abcde'
        }
        ctrl.project = Immutable.fromJS({
            id: 1
        })

        project = ctrl.project.get('id')
        message = ctrl.contact.message

        promise = mocks.tgResources.projects.contactProject.withArgs(project, message).promise().resolve()

        ctrl.sendingFeedback = true

        ctrl.contactProject().then () ->
            expect(mocks.tglightboxService.closeAll).have.been.called
            expect(ctrl.sendingFeedback).to.be.false
            expect(mocks.tgConfirm.notify).have.been.calledWith("success")
            done()
