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

describe "StoryHeaderComponent", ->
    headerDetailCtrl =  null
    provide = null
    controller = null
    rootScope = null
    mocks = {}

    _mockRootScope = () ->
        mocks.rootScope = {
            $broadcast: sinon.stub()
        }

        provide.value "$rootScope", mocks.rootScope

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgQueueModelTransformation = () ->
        mocks.modelTransform = {
            save: sinon.stub()
        }

        provide.value "$tgQueueModelTransformation", mocks.tgQueueModelTransformation

    _mockTgNav = () ->
        mocks.navUrls = {
            resolve: sinon.stub().returns('project-issues-detail')
        }

        provide.value "$tgNavUrls", mocks.navUrls

    _mockWindow = () ->
        mocks.window = {
            getSelection: sinon.stub()
        }

        provide.value "$window", mocks.window

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockRootScope()
            _mockTgConfirm()
            _mockTgQueueModelTransformation()
            _mockTgNav()
            _mockWindow()

            return null

    beforeEach ->
        module "taigaUserStories"

        _mocks()

        inject ($controller) ->
            controller = $controller

            headerDetailCtrl = controller "StoryHeaderCtrl", {}, {
                item: {
                    subject: 'Example subject'
                }
            }

        headerDetailCtrl.originalSubject = headerDetailCtrl.item.subject

    it "previous item neighbor", () ->
        headerDetailCtrl.project = {
            slug: 'example_subject'
        }
        headerDetailCtrl.item.neighbors = {
            previous: {
                ref: 42
            }
        }
        headerDetailCtrl._checkNav()
        headerDetailCtrl.previousUrl = mocks.navUrls.resolve("project-issues-detail")
        expect(headerDetailCtrl.previousUrl).to.be.equal("project-issues-detail")

    it "check permissions", () ->
        headerDetailCtrl.project = {
            my_permissions: ['view_us']
        }
        headerDetailCtrl.requiredPerm = 'view_us'
        headerDetailCtrl._checkPermissions()
        expect(headerDetailCtrl.permissions).to.be.eql({canEdit: true})

    it "edit subject without selection", () ->
        mocks.window.getSelection.returns({
            type: 'Range'
        })
        headerDetailCtrl.editSubject(true)
        expect(headerDetailCtrl.editMode).to.be.false

    it "edit subject on click", () ->
        mocks.window.getSelection.returns({
            type: 'potato'
        })
        headerDetailCtrl.editSubject(true)
        expect(headerDetailCtrl.editMode).to.be.true

    it "do not edit subject", () ->
        mocks.window.getSelection.returns({
            type: 'Range'
        })
        headerDetailCtrl.editSubject(false)
        expect(headerDetailCtrl.editMode).to.be.false

    it "save on keydown Enter", () ->
        event = {}
        event.which = 13
        headerDetailCtrl.saveSubject = sinon.stub()
        headerDetailCtrl.onKeyDown(event)
        expect(headerDetailCtrl.saveSubject).have.been.called

    it "don't save on keydown ESC", () ->
        event = {}
        event.which = 27
        headerDetailCtrl.editSubject = sinon.stub()
        headerDetailCtrl.onKeyDown(event)
        expect(headerDetailCtrl.item.subject).to.be.equal(headerDetailCtrl.originalSubject)
        expect(headerDetailCtrl.editSubject).have.been.calledWith(false)
