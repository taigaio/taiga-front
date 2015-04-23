class FeedbackService extends taiga.Service
    constructor: ->
        @.emiter = new EventEmitter2()

    sendFeedback: ->
        @.emiter.emit("send")

angular.module("taigaFeedback").service("tgFeedback", FeedbackService)
