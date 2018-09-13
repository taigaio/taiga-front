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
# File: projects/create/create-project.controller.spec.coffee
###

describe "CreateProjectController", ->
    provide = null
    controller = null
    mocks = {}

    _inject = (callback) ->
        inject (_$controller_, _$q_, _$rootScope_) ->
            controller = _$controller_

    beforeEach ->
        module "taigaProjects"
        _inject()

    # it "get Home Step", () ->
    #     ctrl = controller "CreateProjectCtrl"
    #     ctrl.inDefaultStep = true
    #     ctrl.getStep('home')
    #     expect(ctrl.inDefaultStep).to.be.true
    #     expect(ctrl.inStepDuplicateProject).to.be.false
    #
    # it "get Duplicate Project Step", () ->
    #     ctrl = controller "CreateProjectCtrl"
    #     ctrl.inDefaultStep = true
    #     ctrl.getStep('duplicate')
    #     expect(ctrl.inDefaultStep).to.be.false
    #     expect(ctrl.inStepDuplicateProject).to.be.true
