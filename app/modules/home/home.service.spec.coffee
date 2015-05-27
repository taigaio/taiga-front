describe "tgHome", ->
    homeService = provide = null
    mocks = {}

    _mockResources = () ->
        mocks.resources = {}

        mocks.resources.userstories = {}
        mocks.resources.tasks = {}
        mocks.resources.issues = {}

        mocks.resources.userstories.listInAllProjects = sinon.stub()
        mocks.resources.tasks.listInAllProjects = sinon.stub()
        mocks.resources.issues.listInAllProjects = sinon.stub()

        provide.value "tgResources", mocks.resources

    _mockTgNavUrls = () ->
        mocks.tgNavUrls = {
            resolve: sinon.stub()
        }

        provide.value "$tgNavUrls", mocks.tgNavUrls

    _mockProjectsService = () ->
        mocks.projectsService = {
            getProjectsByUserId: sinon.stub().promise()
        }

        provide.value "tgProjectsService", mocks.projectsService

    _inject = (callback) ->
        inject (_tgHomeService_) ->
            homeService = _tgHomeService_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockResources()
            _mockTgNavUrls()
            _mockProjectsService()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaHome"
        _setup()
        _inject()

    it "get work in progress by user", (done) ->
        userId = 3

        mocks.projectsService.getProjectsByUserId
            .withArgs(userId)
            .resolve(Immutable.fromJS([
                {id: 1, name: "fake1", slug: "project-1"},
                {id: 2, name: "fake2", slug: "project-2"}
            ]))

        mocks.resources.userstories.listInAllProjects.promise()
            .resolve(Immutable.fromJS([{id: 1, ref: 1, project: "1"}]))

        mocks.resources.tasks.listInAllProjects.promise()
            .resolve(Immutable.fromJS([{id: 2, ref: 2, project: "1"}]))

        mocks.resources.issues.listInAllProjects.promise()
            .resolve(Immutable.fromJS([{id: 3, ref: 3, project: "1"}]))

        # mock urls
        mocks.tgNavUrls.resolve
            .withArgs("project-userstories-detail", {project: "project-1", ref: 1})
            .returns("/testing-project/us/1")

        mocks.tgNavUrls.resolve
            .withArgs("project-tasks-detail", {project: "project-1", ref: 2})
            .returns("/testing-project/tasks/1")

        mocks.tgNavUrls.resolve
            .withArgs("project-issues-detail", {project: "project-1", ref: 3})
            .returns("/testing-project/issues/1")

        homeService.getWorkInProgress(userId)
            .then (workInProgress) ->
                expect(workInProgress.toJS()).to.be.eql({
                    assignedTo: {
                        userStories: [{
                            id: 1,
                            ref: 1,
                            project: '1',
                            url: '/testing-project/us/1',
                            projectName: 'fake1',
                            _name: 'userstories'
                        }]
                        tasks: [{
                            id: 2,
                            ref: 2,
                            project: '1',
                            url: '/testing-project/tasks/1',
                            projectName: 'fake1',
                            _name: 'tasks'
                        }]
                        issues: [{
                            id: 3,
                            ref: 3,
                            project: '1',
                            url: '/testing-project/issues/1',
                            projectName: 'fake1',
                            _name: 'issues'
                        }]
                    }
                    watching: {
                        userStories: [{
                            id: 1,
                            ref: 1,
                            project: '1',
                            url: '/testing-project/us/1',
                            projectName: 'fake1',
                            _name: 'userstories'
                        }]
                        tasks: [{
                            id: 2,
                            ref: 2,
                            project: '1',
                            url: '/testing-project/tasks/1',
                            projectName: 'fake1',
                            _name: 'tasks'
                        }]
                        issues: [{
                            id: 3,
                            ref: 3,
                            project: '1',
                            url: '/testing-project/issues/1',
                            projectName: 'fake1',
                            _name: 'issues'
                        }]
                    }
                })

                done()
