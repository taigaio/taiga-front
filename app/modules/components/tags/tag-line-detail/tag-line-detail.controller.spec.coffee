###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "TagLineDetail", ->
    provide = null
    controller = null
    TagLineController = null
    mocks = {}

    _mockRootScope = () ->
        mocks.rootScope = {
            $broadcast: sinon.stub()
        }

        provide.value "$rootScope", mocks.rootScope

    _mockTgConfirm = () ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        provide.value "$tgConfirm", mocks.tgConfirm

    _mockTgQueueModelTransformation = () ->
        mocks.tgQueueModelTransformation = {
            save: sinon.stub()
        }

        provide.value "$tgQueueModelTransformation", mocks.tgQueueModelTransformation


    _mocks = () ->
        module ($provide) ->
            provide = $provide
            _mockRootScope()
            _mockTgConfirm()
            _mockTgQueueModelTransformation()

            return null

    beforeEach ->
        module "taigaCommon"

        _mocks()

        inject ($controller) ->
            controller = $controller

        TagLineController = controller "TagLineCtrl"

    it "on delete tag success", (done) ->
        tag = {
            name: 'tag1'
        }
        tagName = tag.name

        item = {
            tags: [
                ['tag1'],
                ['tag2'],
                ['tag3']
            ]
        }

        mocks.tgQueueModelTransformation.save.callsArgWith(0, item)
        mocks.tgQueueModelTransformation.save.promise().resolve(item)

        TagLineController.onDeleteTag(['tag1', '#000']).then (item) ->
            expect(item.tags).to.be.eql([
                ['tag2'],
                ['tag3']
            ])
            expect(TagLineController.loadingRemoveTag).to.be.false
            expect(mocks.rootScope.$broadcast).to.be.calledWith("object:updated")
            done()

    it "on delete tag error", (done) ->
        mocks.tgQueueModelTransformation.save.promise().reject(new Error('error'))

        TagLineController.onDeleteTag(['tag1']).finally () ->
            expect(TagLineController.loadingRemoveTag).to.be.false
            expect(mocks.tgConfirm.notify).to.be.calledWith("error")
            done()

    it "on add tag success", (done) ->
        tag = 'tag1'
        tagColor = '#eee'

        item = {
            tags: [
                ['tag2'],
                ['tag3']
            ]
        }

        mockPromise = mocks.tgQueueModelTransformation.save.promise()

        mocks.tgQueueModelTransformation.save.callsArgWith(0, item)
        promise = TagLineController.onAddTag(tag, tagColor)

        expect(TagLineController.loadingAddTag).to.be.true

        mockPromise.resolve(item)

        promise.then (item) ->
            expect(item.tags).to.be.eql([
                ['tag2'],
                ['tag3'],
                ['tag1', '#eee']
            ])

            expect(mocks.rootScope.$broadcast).to.be.calledWith("object:updated")
            expect(TagLineController.addTag).to.be.false
            expect(TagLineController.loadingAddTag).to.be.false

            done()

    it "on add tag error", (done) ->
        tag = 'tag1'
        tagColor = '#eee'

        item = {
            tags: [
                ['tag2'],
                ['tag3']
            ]
        }

        mockPromise = mocks.tgQueueModelTransformation.save.promise()

        mocks.tgQueueModelTransformation.save.callsArgWith(0, item)
        promise = TagLineController.onAddTag(tag, tagColor)

        expect(TagLineController.loadingAddTag).to.be.true

        mockPromise.reject(new Error('error'))

        promise.then (item) ->
            expect(TagLineController.loadingAddTag).to.be.false
            expect(mocks.tgConfirm.notify).to.be.calledWith("error")
            done()
