###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "WorkingOn", ->
    $controller = null
    $provide = null
    mocks = {}

    _mockHomeService = () ->
        mocks.homeService = {
            getWorkInProgress: sinon.stub()
        }

        $provide.value("tgHomeService", mocks.homeService)

    _mocks = () ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockHomeService()

            return null

    _inject = () ->
        inject (_$controller_) ->
            $controller = _$controller_

    beforeEach ->
        module "taigaHome"
        _mocks()
        _inject()

    it "get work in progress items", (done) ->
        userId = 3

        workInProgress = Immutable.fromJS({
            assignedTo: {
                epics: [
                    {id: 7, modified_date: "2015-01-08"},
                    {id: 8, modified_date: "2015-01-07"}],
                userStories: [
                    {id: 1, modified_date: "2015-01-01"},
                    {id: 2, modified_date: "2015-01-04"}],
                tasks: [
                    {id: 3, modified_date: "2015-01-02"},
                    {id: 4, modified_date: "2015-01-05"}],
                issues: [
                    {id: 5, modified_date: "2015-01-03"},
                    {id: 6, modified_date: "2015-01-06"}]
            },
            watching: {
                epics: [
                    {id: 13, modified_date: "2015-01-07"},
                    {id: 14, modified_date: "2015-01-08"}],
                userStories: [
                    {id: 7, modified_date: "2015-01-01"},
                    {id: 8, modified_date: "2015-01-04"}],
                tasks: [
                    {id: 9, modified_date: "2015-01-02"},
                    {id: 10, modified_date: "2015-01-05"}],
                issues: [
                    {id: 11, modified_date: "2015-01-03"},
                    {id: 12, modified_date: "2015-01-06"}]
            }
        })

        mocks.homeService.getWorkInProgress.withArgs(userId).promise().resolve(workInProgress)

        ctrl = $controller("WorkingOn")

        ctrl.getWorkInProgress(userId).then () ->
            expect(ctrl.assignedTo.toJS()).to.be.eql([
                {id: 7, modified_date: '2015-01-08'},
                {id: 8, modified_date: '2015-01-07'},
                {id: 6, modified_date: '2015-01-06'},
                {id: 4, modified_date: '2015-01-05'},
                {id: 2, modified_date: '2015-01-04'},
                {id: 5, modified_date: '2015-01-03'},
                {id: 3, modified_date: '2015-01-02'},
                {id: 1, modified_date: '2015-01-01'}
            ])

            expect(ctrl.watching.toJS()).to.be.eql([
                {id: 14, modified_date: '2015-01-08'},
                {id: 13, modified_date: '2015-01-07'},
                {id: 12, modified_date: '2015-01-06'},
                {id: 10, modified_date: '2015-01-05'},
                {id: 8, modified_date: '2015-01-04'},
                {id: 11, modified_date: '2015-01-03'},
                {id: 9, modified_date: '2015-01-02'},
                {id: 7, modified_date: '2015-01-01'}
            ])

            done()
