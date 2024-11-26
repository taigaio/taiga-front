###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaHistory")

class LightboxDisplayHistoricController
    @.$inject = [
        "$tgResources",
    ]

    constructor: (@rs) ->

    _loadHistoric: () ->
        type = @.name
        objectId = @.object
        activityId = @.comment.id

        @rs.history.getCommentHistory(type, objectId, activityId).then (data) =>
            @.commentHistoryEntries = data

module.controller("LightboxDisplayHistoricCtrl", LightboxDisplayHistoricController)
