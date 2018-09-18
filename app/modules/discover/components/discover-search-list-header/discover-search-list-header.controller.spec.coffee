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
# File: discover/components/discover-search-list-header/discover-search-list-header.controller.spec.coffee
###

describe "DiscoverSearchListHeader", ->
    $provide = null
    $controller = null
    scope = null

    _inject = ->
        inject (_$controller_, $rootScope) ->
            $controller = _$controller_
            scope = $rootScope.$new()

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaDiscover"

        _setup()

    it "openLike", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: ''
        })

        ctrl.like_is_open = false
        ctrl.activity_is_open = true
        ctrl.setOrderBy = sinon.spy()

        ctrl.openLike()

        expect(ctrl.like_is_open).to.be.true
        expect(ctrl.activity_is_open).to.be.false
        expect(ctrl.setOrderBy).have.been.calledWith('-total_fans_last_week')

    it "openActivity", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: ''
        })

        ctrl.activity_is_open = false
        ctrl.like_is_open = true
        ctrl.setOrderBy = sinon.spy()

        ctrl.openActivity()

        expect(ctrl.activity_is_open).to.be.true
        expect(ctrl.like_is_open).to.be.false
        expect(ctrl.setOrderBy).have.been.calledWith('-total_activity_last_week')

    it "setOrderBy", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: ''
        })

        ctrl.onChange = sinon.spy()

        ctrl.setOrderBy("type1")

        expect(ctrl.onChange).to.have.been.calledWith(sinon.match({orderBy: "type1"}))

    it "setOrderBy falsy close the like or activity layer", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: ''
        })

        ctrl.like_is_open = true
        ctrl.activity_is_open = true

        ctrl.onChange = sinon.spy()

        ctrl.setOrderBy()

        expect(ctrl.onChange).to.have.been.calledWith(sinon.match({orderBy: ''}))
        expect(ctrl.like_is_open).to.be.false
        expect(ctrl.activity_is_open).to.be.false

    it "closed like & activity", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: ''
        })

        expect(ctrl.like_is_open).to.be.false
        expect(ctrl.activity_is_open).to.be.false

    it "open like", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: '-total_fans'
        })

        expect(ctrl.like_is_open).to.be.true
        expect(ctrl.activity_is_open).to.be.false

    it "open activity", () ->
        ctrl = $controller("DiscoverSearchListHeader", scope, {
            orderBy: '-total_activity'
        })

        expect(ctrl.like_is_open).to.be.false
        expect(ctrl.activity_is_open).to.be.true
