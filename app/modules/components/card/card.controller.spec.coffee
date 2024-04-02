###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "Card", ->
    $provide = null
    $controller = null
    scope = null
    mocks = {}

    _inject = ->
        inject (_$controller_, $rootScope) ->
            $controller = _$controller_
            scope = $rootScope.$new()

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "toggle fold callback", () ->
        ctrl = $controller("Card", {
            $scope: scope
        })

        ctrl.item = Immutable.fromJS({id: 2})
        ctrl.onToggleFold = sinon.spy()

        ctrl.toggleFold()

        expect(ctrl.onToggleFold).to.have.been.calledWith({id: 2})

    it "get closed tasks", () ->
        ctrl = $controller("Card", {
            $scope: scope
        })

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
        ctrl = $controller("Card", {
            $scope: scope
        })

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
            ctrl = $controller("Card", {
                $scope: scope
            })

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
            ctrl = $controller("Card", {
                $scope: scope
            })

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
            ctrl = $controller("Card", {
                $scope: scope
            })

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
