###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgUserTimelinePaginationSequenceService", ->
    userTimelinePaginationSequenceService = null

    _inject = () ->
        inject (_tgUserTimelinePaginationSequenceService_) ->
            userTimelinePaginationSequenceService = _tgUserTimelinePaginationSequenceService_

    beforeEach ->
        module "taigaUserTimeline"
        _inject()

    it "get remote items to reach the min", (done) ->
        config = {}

        page1 = Immutable.Map({
            next: true,
            data: [1, 2, 3]
        })
        page2 = Immutable.Map({
            next: true,
            data: [4, 5]
        })
        page3 = Immutable.Map({
            next: true,
            data: [6, 7, 8, 9, 10, 11]
        })

        promise = sinon.stub()
        promise.withArgs(1).promise().resolve(page1)
        promise.withArgs(2).promise().resolve(page2)
        promise.withArgs(3).promise().resolve(page3)

        config.fetch = (page) ->
            return promise(page)

        config.minItems = 10

        seq = userTimelinePaginationSequenceService.generate(config)

        seq.next().then (result) ->
            result = result.toJS()

            expect(result.items).to.have.length(11)
            expect(result.next).to.be.true

            done()

    it "get items until the last page", (done) ->
        config = {}

        page1 = Immutable.Map({
            next: true,
            data: [1, 2, 3]
        })
        page2 = Immutable.Map({
            next: false,
            data: [4, 5]
        })

        promise = sinon.stub()
        promise.withArgs(1).promise().resolve(page1)
        promise.withArgs(2).promise().resolve(page2)

        config.fetch = (page) ->
            return promise(page)

        config.minItems = 10

        seq = userTimelinePaginationSequenceService.generate(config)

        seq.next().then (result) ->
            result = result.toJS()

            expect(result.items).to.have.length(5)
            expect(result.next).to.be.false

            done()

    it "increase pagination every page call", (done) ->
        config = {}

        page1 = Immutable.Map({
            next: true,
            data: [1, 2, 3]
        })
        page2 = Immutable.Map({
            next: true,
            data: [4, 5]
        })

        promise = sinon.stub()
        promise.withArgs(1).promise().resolve(page1)
        promise.withArgs(2).promise().resolve(page2)

        config.fetch = (page) ->
            return promise(page)

        config.minItems = 2

        seq = userTimelinePaginationSequenceService.generate(config)

        seq.next().then () ->
            seq.next().then (result) ->
                result = result.toJS()

                expect(result.items).to.have.length(2)
                expect(result.next).to.be.true

                done()


    it "map items", (done) ->
        config = {}

        page1 = Immutable.Map({
            next: false,
            data: [1, 2, 3]
        })

        promise = sinon.stub()
        promise.withArgs(1).promise().resolve(page1)

        config.fetch = (page) ->
            return promise(page)

        config.minItems = 1

        config.map = (item) => item + 1

        seq = userTimelinePaginationSequenceService.generate(config)

        seq.next().then (result) ->
            result = result.toJS()

            expect(result.items).to.be.eql([2, 3, 4])

            done()
