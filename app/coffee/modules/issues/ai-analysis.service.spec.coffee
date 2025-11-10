###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "AiAnalysisService", ->
    $provide = null
    aiAnalysisService = null
    mocks = {}

    _mockTranslate = ->
        mocks.translate = {
            instant: sinon.stub()
        }
        $provide.value("$translate", mocks.translate)

    _mockHttp = ->
        mocks.http = {
            post: sinon.stub()
        }
        $provide.value("$http", mocks.http)

    _mockConfig = ->
        mocks.config = {
            get: sinon.stub().returns("http://localhost:8000/api/v1")
        }
        $provide.value("$tgConfig", mocks.config)

    _inject = ->
        inject (_tgAiAnalysisService_) ->
            aiAnalysisService = _tgAiAnalysisService_

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTranslate()
            _mockHttp()
            _mockConfig()

            return null

    _setup = ->
        _mocks()

    beforeEach ->
        module "taigaIssues"
        _setup()
        _inject()

    describe "analyzeIssues", ->
        it "should return a promise", ->
            promise = aiAnalysisService.analyzeIssues(123, [])
            expect(promise).to.have.property('then')
            expect(promise).to.have.property('catch')

        it "should generate mock analysis for all issues", (done) ->
            issues = [
                {id: 1, ref: 101, subject: "Test Issue 1"},
                {id: 2, ref: 102, subject: "Test Issue 2"}
            ]

            promise = aiAnalysisService.analyzeIssues(123, issues)
            
            promise.then (results) ->
                expect(results).to.be.an('array')
                expect(results.length).to.equal(2)
                expect(results[0].issueId).to.equal(1)
                expect(results[1].issueId).to.equal(2)
                done()

        it "should include all required fields in analysis", (done) ->
            issues = [{id: 1, ref: 101, subject: "Test Issue"}]

            promise = aiAnalysisService.analyzeIssues(123, issues)
            
            promise.then (results) ->
                analysis = results[0].analysis
                expect(analysis).to.have.property('priority')
                expect(analysis).to.have.property('priorityReason')
                expect(analysis).to.have.property('type')
                expect(analysis).to.have.property('severity')
                expect(analysis).to.have.property('description')
                expect(analysis).to.have.property('relatedModules')
                expect(analysis).to.have.property('solutions')
                expect(analysis).to.have.property('confidence')
                done()

        it "should generate 2-4 related modules", (done) ->
            issues = [{id: 1, ref: 101, subject: "Test Issue"}]

            promise = aiAnalysisService.analyzeIssues(123, issues)
            
            promise.then (results) ->
                modules = results[0].analysis.relatedModules
                expect(modules).to.be.an('array')
                expect(modules.length).to.be.at.least(2)
                expect(modules.length).to.be.at.most(4)
                done()

        it "should generate 3-5 solutions", (done) ->
            issues = [{id: 1, ref: 101, subject: "Test Issue"}]

            promise = aiAnalysisService.analyzeIssues(123, issues)
            
            promise.then (results) ->
                solutions = results[0].analysis.solutions
                expect(solutions).to.be.an('array')
                expect(solutions.length).to.be.at.least(3)
                expect(solutions.length).to.be.at.most(5)
                done()

        it "should handle empty issue list", (done) ->
            promise = aiAnalysisService.analyzeIssues(123, [])
            
            promise.then (results) ->
                expect(results).to.be.an('array')
                expect(results.length).to.equal(0)
                done()

    describe "_formatIssuesForApi", ->
        it "should format issue with all fields", ->
            issues = [
                {
                    id: 1,
                    ref: 101,
                    subject: "Test Issue",
                    description: "Test Description",
                    type: {name: "Bug"},
                    priority: {name: "High"},
                    severity: {name: "Critical"},
                    status: {name: "New"},
                    tags: ["tag1", "tag2"]
                }
            ]

            formatted = aiAnalysisService._formatIssuesForApi(issues)
            
            expect(formatted).to.be.an('array')
            expect(formatted[0].id).to.equal(1)
            expect(formatted[0].ref).to.equal(101)
            expect(formatted[0].subject).to.equal("Test Issue")
            expect(formatted[0].type).to.equal("Bug")
            expect(formatted[0].priority).to.equal("High")
            expect(formatted[0].severity).to.equal("Critical")

        it "should handle missing optional fields", ->
            issues = [
                {
                    id: 1,
                    ref: 101,
                    subject: "Test Issue"
                }
            ]

            formatted = aiAnalysisService._formatIssuesForApi(issues)
            
            expect(formatted[0].description).to.equal("")
            expect(formatted[0].type).to.equal("")
            expect(formatted[0].tags).to.be.an('array')

    describe "_shuffleArray", ->
        it "should return array with same length", ->
            arr = [1, 2, 3, 4, 5]
            shuffled = aiAnalysisService._shuffleArray(arr)
            
            expect(shuffled).to.be.an('array')
            expect(shuffled.length).to.equal(arr.length)

        it "should contain all original elements", ->
            arr = [1, 2, 3, 4, 5]
            shuffled = aiAnalysisService._shuffleArray(arr)
            
            for item in arr
                expect(shuffled).to.include(item)

        it "should not modify original array", ->
            arr = [1, 2, 3, 4, 5]
            original = arr.slice()
            aiAnalysisService._shuffleArray(arr)
            
            expect(arr).to.deep.equal(original)

    describe "_getPriorityReason", ->
        it "should return reason for Low priority", ->
            reason = aiAnalysisService._getPriorityReason("Low")
            expect(reason).to.be.a('string')
            expect(reason.length).to.be.greaterThan(0)

        it "should return reason for Normal priority", ->
            reason = aiAnalysisService._getPriorityReason("Normal")
            expect(reason).to.be.a('string')
            expect(reason.length).to.be.greaterThan(0)

        it "should return reason for High priority", ->
            reason = aiAnalysisService._getPriorityReason("High")
            expect(reason).to.be.a('string')
            expect(reason.length).to.be.greaterThan(0)

        it "should return default for unknown priority", ->
            reason = aiAnalysisService._getPriorityReason("Unknown")
            expect(reason).to.be.a('string')
            expect(reason).to.contain("evaluation")
