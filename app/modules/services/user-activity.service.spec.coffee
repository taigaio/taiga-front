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
# File: services/user-activity.service.spec.coffee
###

angular.module("taigaCommon").provider("$exceptionHandler", angular.mock.$ExceptionHandlerProvider)

describe "UserActivityService", ->
    userActivityService = null
    $timeout = null

    _inject = () ->
        inject (_tgUserActivityService_, _$timeout_) ->
            userActivityService = _tgUserActivityService_
            $timeout = _$timeout_

    beforeEach ->
        module "taigaCommon"
        _inject()

    it "inactive", (done) ->
        active = sinon.spy()
        userActivityService.onInactive () ->
            expect(active).not.to.have.been.called;
            done()

        userActivityService.onActive(active)

        $timeout.flush()

    it "unsubscribe inactive", (done) ->
        unsubscribe = userActivityService.onInactive () ->
            unsubscribe()

            expect(userActivityService.subscriptionsInactive).to.have.length(0)

            done()

        expect(userActivityService.subscriptionsInactive).to.have.length(1)

        $timeout.flush()

    it "active", (done) ->
        inactive = sinon.spy()
        userActivityService.onInactive(inactive)

        userActivityService.onActive () ->
            expect(inactive).to.have.been.called;
            done()

        $timeout.flush()
        userActivityService.resetTimer()

    it "unsubscribe active", (done) ->
        unsubscribe = userActivityService.onActive () ->
            unsubscribe()

            expect(userActivityService.subscriptionsActive).to.have.length(0)

            done()

        expect(userActivityService.subscriptionsActive).to.have.length(1)

        $timeout.flush()
        userActivityService.resetTimer()
