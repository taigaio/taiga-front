###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
