###
# Service for feedback-full (optional, for feedback API calls)
###

class TaskFeedbacksService
    @$inject: ["$tgRepo"]
    constructor: (@tgRepo) ->
        null

    createFeedback: (payload) ->
        @tgRepo.create("userstory-feedback", payload)

    updateFeedback: (feedbackModel, payload) ->
        feedbackModel.feedback_text = payload.feedback_text
        feedbackModel.rating = payload.rating
        @tgRepo.save(feedbackModel, true)

    deleteFeedback: (feedbackModel) ->
        @tgRepo.remove(feedbackModel)

angular.module("taigaComponents").service("TaskFeedbacksService", TaskFeedbacksService)
