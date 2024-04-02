###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "AttachmentsPreviewController", ->
    $provide = null
    $controller = null
    scope = null
    mocks = {}

    _mockAttachmentsPreviewService = ->
        mocks.attachmentsPreviewService = {}

        $provide.value("tgAttachmentsPreviewService", mocks.attachmentsPreviewService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockAttachmentsPreviewService()

            return null

    _inject = ->
        inject (_$controller_, $rootScope) ->
            $controller = _$controller_
            scope = $rootScope.$new()

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaComponents"

        _setup()

    it "get current file", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })


        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1
                }
            },
            {
                file: {
                    id: 2
                }
            },
            {
                file: {
                    id: 3
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 2

        current = ctrl.getCurrent()

        expect(current.get('id')).to.be.equal(2)
        expect(ctrl.current.get('id')).to.be.equal(2)


    it "has pagination", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })

        ctrl.getIndex = sinon.stub().returns(0)


        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 2,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 3,
                    name: "xx.jpg"
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 1

        pagination = ctrl.hasPagination()

        expect(pagination).to.be.false

        ctrl.attachments = ctrl.attachments.push(Immutable.fromJS({
            file: {
                id: 4,
                name: "xx.jpg"
            }
        }))

        pagination = ctrl.hasPagination()

        expect(pagination).to.be.true

    it "get index", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })


        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1
                }
            },
            {
                file: {
                    id: 2
                }
            },
            {
                file: {
                    id: 3
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 2

        currentIndex = ctrl.getIndex()

        expect(currentIndex).to.be.equal(1)

    it "next", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })

        ctrl.getIndex = sinon.stub().returns(0)


        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 2,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 3,
                    name: "xx.jpg"
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 1

        currentIndex = ctrl.next()

        expect(mocks.attachmentsPreviewService.fileId).to.be.equal(3)

    it "next infinite", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })

        ctrl.getIndex = sinon.stub().returns(2)

        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1,
                    name: "xx.jpg"
                }
            },
            {
                file: {
                    id: 2,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 3,
                    name: "xx.jpg"
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 3

        currentIndex = ctrl.next()

        expect(mocks.attachmentsPreviewService.fileId).to.be.equal(1)

    it "previous", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })

        ctrl.getIndex = sinon.stub().returns(2)


        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1,
                    name: "xx.jpg"
                }
            },
            {
                file: {
                    id: 2,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 3,
                    name: "xx.jpg"
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 3

        currentIndex = ctrl.previous()

        expect(mocks.attachmentsPreviewService.fileId).to.be.equal(1)

     it "previous infinite", () ->
        attachment = Immutable.fromJS({
            file: {
                description: 'desc',
                is_deprecated: false
            }
        })

        ctrl = $controller("AttachmentsPreview", {
            $scope: scope
        })

        ctrl.getIndex = sinon.stub().returns(0)

        ctrl.attachments = Immutable.fromJS([
            {
                file: {
                    id: 1,
                    name: "xx.jpg"
                }
            },
            {
                file: {
                    id: 2,
                    name: "xx"
                }
            },
            {
                file: {
                    id: 3,
                    name: "xx.jpg"
                }
            }
        ])

        mocks.attachmentsPreviewService.fileId = 1

        currentIndex = ctrl.previous()

        expect(mocks.attachmentsPreviewService.fileId).to.be.equal(3)
