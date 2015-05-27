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
                userStories: [{id: 1}, {id: 2}],
                tasks: [{id: 3}, {id: 4}],
                issues: [{id: 5}, {id: 6}]
            },
            watching: {
                userStories: [{id: 7}, {id: 8}],
                tasks: [{id: 9}, {id: 10}],
                issues: [{id: 11}, {id: 12}]
            }
        })

        mocks.homeService.getWorkInProgress.withArgs(userId).promise().resolve(workInProgress)

        ctrl = $controller("WorkingOn")

        ctrl.getWorkInProgress(userId).then () ->
            expect(ctrl.assignedTo.toJS()).to.be.eql([
                {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}
            ])

            expect(ctrl.watching.toJS()).to.be.eql([
                {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11}, {id: 12}
            ])

            done()
