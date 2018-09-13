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
# File: components/card/card.controller.spec.coffee
###

describe "Card", ->
    $provide = null
    $controller = null
    mocks = {}

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "toggle fold callback", () ->
        ctrl = $controller("Card")

        ctrl.item = Immutable.fromJS({id: 2})
        ctrl.onToggleFold = sinon.spy()

        ctrl.toggleFold()

        expect(ctrl.onToggleFold).to.have.been.calledWith({id: 2})

    it "get closed tasks", () ->
        ctrl = $controller("Card")

        ctrl.item = Immutable.fromJS({
            id: 2,
            model: {
                tasks: [
                    {is_closed: true},
                    {is_closed: false},
                    {is_closed: true}
                ]
            }
        })

        tasks = ctrl.getClosedTasks()
        expect(tasks.size).to.be.equal(2)

    it "get closed percent", () ->
        ctrl = $controller("Card")

        ctrl.item = Immutable.fromJS({
            id: 2,
            model: {
                tasks: [
                    {is_closed: true},
                    {is_closed: false},
                    {is_closed: false},
                    {is_closed: true}
                ]
            }
        })

        percent = ctrl.closedTasksPercent()
        expect(percent).to.be.equal(50)

    describe "check if related task and slides visibility", () ->
        it "no content", () ->
            ctrl = $controller("Card")

            ctrl.item = Immutable.fromJS({
                id: 2,
                images: [],
                model: {
                    tasks: []
                }
            })

            ctrl.visible = () => return true

            visibility = ctrl._setVisibility()

            expect(visibility).to.be.eql({
                related: false,
                slides: false
            })

        it "with content", () ->
            ctrl = $controller("Card")

            ctrl.item = Immutable.fromJS({
                id: 2,
                images: [3,4],
                model: {
                    tasks: [1,2]
                }
            })

            ctrl.visible = () => return true

            visibility = ctrl._setVisibility()

            expect(visibility).to.be.eql({
                related: true,
                slides: true
            })

        it "fold", () ->
            ctrl = $controller("Card")

            ctrl.item = Immutable.fromJS({
                foldStatusChanged: true,
                id: 2,
                images: [3,4],
                model: {
                    tasks: [1,2]
                }
            })

            ctrl.visible = () => return true

            visibility = ctrl._setVisibility()

            expect(visibility).to.be.eql({
                related: false,
                slides: false
            })
