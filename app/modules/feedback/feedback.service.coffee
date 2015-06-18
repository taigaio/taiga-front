class FeedbackService extends taiga.Service
    @.$inject = ["tgLightboxFactory"]

    constructor: (@lightboxFactory) ->

    sendFeedback: ->
        @lightboxFactory.create("tg-lb-feedback", {
            "class": "lightbox lightbox-feedback lightbox-generic-form"
        })

angular.module("taigaFeedback").service("tgFeedbackService", FeedbackService)
