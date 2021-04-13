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
