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
# File: components/due-date/due-date-controller.spec.coffee
###

describe "DueDate", ->
    provide = null
    controller = null
    ctrl = null
    mocks = {}

    dueDateConfig = {
        'us': [
            {"color": "#ff0000", "name": "past due", "days_to_due": 0, "by_default": false},
            {"color": "#00ff00", "name": "normal due", "days_to_due": null, "by_default": true}
            {"color": "#333333", "name": "distant past due", "days_to_due": -7, "by_default": false}
            {"color": "#ffff00", "name": "due soon", "days_to_due": 14, "by_default": false},
        ],
        'task': [
            {"color": "#ff0000", "name": "past due", "days_to_due": 0, "by_default": false},
            {"color": "#00ff00", "name": "normal due", "days_to_due": null, "by_default": true}
            {"color": "#ffff00", "name": "due soon", "days_to_due": 3, "by_default": false}
        ],
        'issue': [
            {"color": "#550000", "name": "past due", "days_to_due": 0, "by_default": false},
            {"color": "#00ff00", "name": "normal due", "days_to_due": null, "by_default": true},
            {"color": "#AAAA00", "name": "due soon", "days_to_due": 7, "by_default": false},
            {"color": "#333333", "name": "distant past due", "days_to_due": -10, "by_default": false}
        ]
    }

    _mockTranslate = () ->
        mocks.$translate = {
            instant: (index) ->
                if index == "COMMON.PICKERDATE.FORMAT"
                    return "DD MMM YYYY"
                return 'Set due date'
        }
        provide.value "$translate", mocks.$translate

    _mockTgProjectService = () ->
        mocks.tgProjectService = {
            project: {
                toJS: () -> {}
            }
        }
        provide.value "tgProjectService", mocks.tgProjectService

    _mockTgLightboxFactory = () ->
        mocks.tgLightboxFactory = {}
        provide.value "tgLightboxFactory", mocks.tgLightboxFactory

    _mockLog = () ->
        mocks.log = {
            error: (msg) -> return msg
        }
        provide.value "$log", mocks.log

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockTranslate()
            _mockTgLightboxFactory()
            _mockTgProjectService()
            _mockLog()
            return null

    _inject = ->
        inject ($controller) ->
            controller = $controller

    beforeEach ->
        module "taigaComponents"
        _mocks()
        _inject()

    describe "when is not set", ->
        beforeEach ->
            ctrl = controller "DueDateCtrl"
            ctrl.dueDate = null
            ctrl.format = 'button'

        it "get title", () ->
            expect(ctrl.title()).to.be.eql('Set due date')

        it "get color", () ->
            expect(ctrl.color()).to.be.eql(null)

    describe "when is set", ->
        normalDue = ['normal due', '#9dce0a']
        dueSoon = ['due soon', '#ff9900']
        pastDue = ['past due', '#ff8a84']

        runs = [
            { objType: 'us', days: -1, expect: pastDue },
            { objType: 'us', days: 15, expect: normalDue },
            { objType: 'us', days: 2, expect: dueSoon },
            { objType: 'task', days: -3, expect: pastDue },
            { objType: 'task', days: 18, expect: normalDue },
            { objType: 'task', days: 5, expect: dueSoon },
            { objType: 'issue', days: -5, expect: pastDue },
            { objType: 'issue', days: 20, expect: normalDue },
            { objType: 'issue', days: 8, expect: dueSoon },
        ]

        beforeEach ->
            ctrl = controller "DueDateCtrl"
            ctrl.format = 'button'

        runs.forEach (run) ->
            it "get appearance in #{run.objType} view with #{run.days} days left", () ->
                ctrl.objType = run.objType
                ctrl.dueDate = moment().add(moment.duration(run.days, "days"))
                formatedDate = ctrl.dueDate.format('DD MMM YYYY')
                expect(ctrl.title()).to.be.eql("#{formatedDate} (#{run.expect[0]})")
                expect(ctrl.color()).to.be.eql(run.expect[1])
