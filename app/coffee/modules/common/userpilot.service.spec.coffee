###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

describe "tgUserPilotService", ->
    userPilotService = provide = null
    JOINED_LIMIT_DAYS = 42
    userData = {}

    _inject = (callback) ->
        inject (_$tgUserPilot_, _$window_) ->
            userPilotService = _$tgUserPilot_
            callback() if callback

    _mocks = () ->
        module ($provide) ->
            provide = $provide
            return null

    _setup = ->
        _mocks()

    _setUserData = (dateJoined, maxPrivateProjects) ->
        data = {
            "id": 9879,
            "date_joined": dateJoined.toISOString(),
            "max_private_projects": maxPrivateProjects,
            "roles": ["admin", "usx"]
        }

        return data

    beforeEach ->
        module "taigaCommon"
        _setup()
        _inject()

    it "check limited user userpilot data", () ->
        joined = new Date
        joined.setDate(joined.getDate() - (JOINED_LIMIT_DAYS + 1))
        data = _setUserData(joined, 1)
        preparedData = userPilotService.prepareUserPilotCustomer(data)
        expect(preparedData["taiga_id"]).to.be.eql(data["id"])
        expect(preparedData["taiga_roles"]).to.be.eql("admin,usx")

    it "check paid user userpilot data", () ->
        data = _setUserData(new Date, null)
        preparedData = userPilotService.prepareUserPilotCustomer(data)
        expect(preparedData["taiga_id"]).to.be.eql(data["id"])
        expect(preparedData["taiga_roles"]).to.be.eql("admin,usx")

    it "check new free user userpilot ID agroupation", () ->
        data = _setUserData(new Date, 1)
        ID = userPilotService.calculateUserPilotId(data)
        expect(ID).to.be.eql(ID)

    it "check new paid user userpilot ID agroupation", () ->
        data = _setUserData(new Date, null)
        ID = userPilotService.calculateUserPilotId(data)
        expect(ID).to.be.eql(ID)

    it "check old free user userpilot ID agroupation", () ->
        joined = new Date
        joined.setDate(joined.getDate() - (JOINED_LIMIT_DAYS + 1))
        data = _setUserData(joined, 1)
        ID = userPilotService.calculateUserPilotId(data)
        expect(ID).to.be.eql(1)

    it "check old paid user userpilot ID agroupation", () ->
        joined = new Date
        joined.setDate(joined.getDate() - (JOINED_LIMIT_DAYS + 1))
        data = _setUserData(joined, null)
        ID = userPilotService.calculateUserPilotId(data)
        expect(ID).to.be.eql(data["id"])

