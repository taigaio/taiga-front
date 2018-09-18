###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: projects/components/watch-project-button/watch-project-button.controller.spec.coffee
###

describe "WatchProjectButton", ->
    $provide = null
    $controller = null
    mocks = {}

    _mockTgConfirm = ->
        mocks.tgConfirm = {
            notify: sinon.stub()
        }

        $provide.value("$tgConfirm", mocks.tgConfirm)

    _mockTgWatchProjectButton = ->
        mocks.tgWatchProjectButton = {
            watch: sinon.stub(),
            unwatch: sinon.stub()
        }

        $provide.value("tgWatchProjectButtonService", mocks.tgWatchProjectButton)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockTgConfirm()
            _mockTgWatchProjectButton()

            return null

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _mocks()
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "toggleWatcherOption", () ->
        ctrl = $controller("WatchProjectButton")

        ctrl.toggleWatcherOptions()

        expect(ctrl.showWatchOptions).to.be.true

        ctrl.toggleWatcherOptions()

        expect(ctrl.showWatchOptions).to.be.false

    it "watch", (done) ->
        notifyLevel = 5
        project = Immutable.fromJS({
            id: 3
        })

        ctrl = $controller("WatchProjectButton")
        ctrl.project = project
        ctrl.showWatchOptions = true

        mocks.tgWatchProjectButton.watch = sinon.stub().promise()

        promise = ctrl.watch(notifyLevel)

        expect(ctrl.loading).to.be.true

        mocks.tgWatchProjectButton.watch.withArgs(project.get('id'), notifyLevel).resolve()

        promise.finally () ->
            expect(mocks.tgWatchProjectButton.watch).to.be.calledOnce
            expect(ctrl.showWatchOptions).to.be.false
            expect(ctrl.loading).to.be.false

            done()

    it "watch the same option", () ->
        notifyLevel = 5
        project = Immutable.fromJS({
            id: 3,
            notify_level: 5
        })

        ctrl = $controller("WatchProjectButton")
        ctrl.project = project

        result = ctrl.watch(notifyLevel)
        expect(result).to.be.falsy

    it "watch, notify error", (done) ->
        notifyLevel = 5
        project = Immutable.fromJS({
            id: 3
        })

        ctrl = $controller("WatchProjectButton")
        ctrl.project = project
        ctrl.showWatchOptions = true

        mocks.tgWatchProjectButton.watch.withArgs(project.get('id'), notifyLevel).promise().reject(new Error('error'))

        ctrl.watch(notifyLevel).finally () ->
            expect(mocks.tgConfirm.notify.withArgs("error")).to.be.calledOnce
            expect(ctrl.showWatchOptions).to.be.false
            expect(ctrl.loading).to.be.false

            done()

    it "unwatch", (done) ->
        project = Immutable.fromJS({
            id: 3
        })

        ctrl = $controller("WatchProjectButton")
        ctrl.project = project
        ctrl.showWatchOptions = true

        mocks.tgWatchProjectButton.unwatch = sinon.stub().promise()

        promise = ctrl.unwatch()

        expect(ctrl.loading).to.be.true

        mocks.tgWatchProjectButton.unwatch.withArgs(project.get('id')).resolve()

        promise.finally () ->
            expect(mocks.tgWatchProjectButton.unwatch).to.be.calledOnce
            expect(ctrl.showWatchOptions).to.be.false

            done()

    it "unwatch, notify error", (done) ->
        project = Immutable.fromJS({
            id: 3
        })

        ctrl = $controller("WatchProjectButton")
        ctrl.project = project
        ctrl.showWatchOptions = true

        mocks.tgWatchProjectButton.unwatch.withArgs(project.get('id')).promise().reject(new Error('error'))

        ctrl.unwatch().finally () ->
            expect(mocks.tgConfirm.notify.withArgs("error")).to.be.calledOnce
            expect(ctrl.showWatchOptions).to.be.false

            done()
