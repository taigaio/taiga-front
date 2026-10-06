###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "InputSearchComponent", ->
    $componentController = null

    beforeEach ->
        module "taigaComponents"

        inject (_$componentController_) ->
            $componentController = _$componentController_

    it "updates the input when its query is cleared externally", ->
        ctrl = $componentController("tgInputSearch", null, {
            q: "authentication"
            change: sinon.stub()
        })

        ctrl.$onChanges({q: {currentValue: "authentication"}})
        ctrl.onChange("authentication")
        ctrl.q = null
        ctrl.$onChanges({q: {currentValue: null}})

        expect(ctrl.searchText).to.equal(null)
