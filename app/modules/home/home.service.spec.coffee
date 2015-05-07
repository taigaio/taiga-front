describe "tgHome", ->
    homeService = provide = timeout = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.userstories = {
            listInAllProjects: sinon.stub()
        }

        mocks.resources.tasks = {
            listInAllProjects: sinon.stub()
        }

        mocks.resources.issues = {
            listInAllProjects: sinon.stub()
        }

        paramsAssignedTo = {
            status__is_closed: false
            assigned_to: 1
        }

        paramsWatching = {
            status__is_closed: false
            watchers: 1
        }

        mocks.thenStubAssignedToUserstories = sinon.stub()
        mocks.resources.userstories.listInAllProjects.withArgs(paramsAssignedTo).returns({
            then: mocks.thenStubAssignedToUserstories
        })

        mocks.thenStubAssignedToTasks = sinon.stub()
        mocks.resources.tasks.listInAllProjects.withArgs(paramsAssignedTo).returns({
            then: mocks.thenStubAssignedToTasks
        })

        mocks.thenStubAssignedToIssues = sinon.stub()
        mocks.resources.issues.listInAllProjects.withArgs(paramsAssignedTo).returns({
            then: mocks.thenStubAssignedToIssues
        })


        mocks.thenStubWatchingUserstories = sinon.stub()
        mocks.resources.userstories.listInAllProjects.withArgs(paramsWatching).returns({
            then: mocks.thenStubWatchingUserstories
        })

        mocks.thenStubWatchingTasks = sinon.stub()
        mocks.resources.tasks.listInAllProjects.withArgs(paramsWatching).returns({
            then: mocks.thenStubWatchingTasks
        })

        mocks.thenStubWatchingIssues = sinon.stub()
        mocks.resources.issues.listInAllProjects.withArgs(paramsWatching).returns({
            then: mocks.thenStubWatchingIssues
        })

        provide.value "$tgResources", mocks.resources

    _mockProjectUrl = () ->
        mocks.projectUrl = {get: sinon.stub()}
        mocks.projectUrl.get = (project) ->
            return "url-" + project.id

        provide.value "$projectUrl", mocks.projectUrl

    _mockAuth = () ->
        mocks.auth = {
            getUser: sinon.stub()
        }

        mocks.auth.getUser.returns(id: 1)

        provide.value "$tgAuth", mocks.auth

    _mockTgNavUrls = () ->
        mocks.tgNavUrls = {
            resolve: sinon.stub()
        }
        provide.value "$tgNavUrls", mocks.tgNavUrls

    _inject = (callback) ->
        inject (_$q_, _$tgResources_, _$rootScope_, _$projectUrl_, _$timeout_, _tgHomeService_) ->
            timeout = _$timeout_
            homeService = _tgHomeService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockProjectUrl()
            _mockAuth()
            _mockTgNavUrls()
            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaHome"
        _setup()
        _inject()

    describe "fetch items", ->
        it "work in progress filled", () ->
            mocks.thenStubAssignedToUserstories.callArg(0, [{"id": 1}])
            mocks.thenStubAssignedToTasks.callArg(0, [{"id": 2}])
            mocks.thenStubAssignedToIssues.callArg(0, [{"id": 3}])
            mocks.thenStubWatchingUserstories.callArg(0, [{"id": 4}])
            mocks.thenStubWatchingTasks.callArg(0, [{"id": 5}])
            mocks.thenStubWatchingIssues.callArg(0, [{"id": 6}])

            timeout.flush()
            expect(homeService.workInProgress.toJS()).to.be.eql({
                assignedTo: {
                    userStories: [{"id": 1}]
                    tasks: [{"id": 2}]
                    issues: [{"id": 3}]
                }
                watching: {
                    userStories: [{"id": 4}]
                    tasks: [{"id": 5}]
                    issues: [{"id": 6}]
                }
            })

        it "_inProgress change to false when tgResources end", () ->
            expect(homeService._inProgress).to.be.true
            timeout.flush()
            expect(homeService._inProgress).to.be.false

        it "project info filled", () ->
            duty = {
                id: 66
                _name: "userstories"
                ref: 123
                project: 1
            }
            mocks.thenStubAssignedToUserstories.callArg(0, [duty])
            mocks.thenStubAssignedToTasks.callArg(0)
            mocks.thenStubAssignedToIssues.callArg(0)
            mocks.thenStubWatchingUserstories.callArg(0)
            mocks.thenStubWatchingTasks.callArg(0)
            mocks.thenStubWatchingIssues.callArg(0)
            timeout.flush()

            projectsById = {
                get: () -> {
                    name: "Testing project"
                    slug: "testing-project"
                }
            }

            mocks.tgNavUrls.resolve
                .withArgs("project-userstories-detail", {project: "testing-project", ref: 123})
                .returns("/testing-project/us/123")

            homeService.attachProjectInfoToWorkInProgress(projectsById)
            expect(homeService.workInProgress.toJS()).to.be.eql({
                assignedTo: {
                    userStories: [
                        {
                            id: 66
                            _name: "userstories"
                            ref: 123
                            project: 1
                            url: "/testing-project/us/123"
                            projectName: "Testing project"
                        }
                    ]
                    tasks: []
                    issues: []
                }
                watching: {
                    userStories: []
                    tasks: []
                    issues: []
                }
            })
