###
# Controller for feedback-full, modeled after attachments-full
###

class TaskFeedbacksController
    @$inject: ["$scope", "$element", "tgCurrentUserService", "$tgRepo", "tgAvatarService", "TaskFeedbacksService", "$translate"]
    constructor: (@$scope, @$element, @tgCurrentUserService, @tgRepo, @tgAvatarService, @TaskFeedbacksService, @translate) ->
        @loading = false
        @error = null
        @feedbacks = []
        @feedbackText = ''
        @ratingOptions = [
            { label: "Poor", value: "poor" }
            { label: "Good", value: "good" }
            { label: "Excellent", value: "excellent" }
            { label: "Amazing", value: "amazing" }
        ]
        @selectedRating = null
        @editingFeedback = null
        @currentUser = @tgCurrentUserService.getUser()

        @isAdmin = ->
            roles = @currentUser?.get('roles') or []
            roles.indexOf('Product Owner') isnt -1 and roles.indexOf('Stakeholder') isnt -1

        @isRequestor = ->
            userId = @currentUser?.get('id')
            requestors = @$scope.$parent?.item?.requestors or []
            requestors.indexOf(userId) isnt -1

        @canViewFeedbackSection = =>
            @isAdmin() or @isRequestor()

        @hasSubmittedFeedback = =>
            userId = @currentUser?.get('id')
            _.some(@feedbacks, (fb) -> fb.user.id is userId)

        @fetchFeedbacks()

    getAvatar: (user) ->
        return @tgAvatarService.getAvatar(user)

    fetchFeedbacks: ->
        userStoryId = @$scope.$parent?.item?.id
        projectId = @$scope.$parent?.item?.project
        return unless userStoryId
        @loading = true
        @tgRepo.queryMany("userstory-feedback", {user_story: userStoryId, project: projectId})
            .then (feedbacks) =>
                @feedbacks = feedbacks.map (fb) =>
                    fb._avatar = @getAvatar(fb.user)
                    fb
                @loading = false
            , (error) =>
                @error = error
                @loading = false

    displayFeedbackModal: (feedback) ->
        if feedback?
            @editingFeedback = feedback
            @selectedRating = feedback.rating
            @feedbackText = feedback.feedback_text
        else
            @editingFeedback = null
            @selectedRating = null
            @feedbackText = ''
        dialog = @$element[0].querySelector('#taskFeedbackDialog')
        dialog?.showModal()

    closeFeedbackModal: ->
        dialog = @$element[0].querySelector('#taskFeedbackDialog')
        dialog?.close()
        @editingFeedback = null
        @selectedRating = null
        @feedbackText = ''
        @error = null

        formCtrl = angular.element(@$element[0].querySelector('form[name="feedbackForm"]')).controller('form')
        if formCtrl?
            formCtrl.$setPristine()
            formCtrl.$setUntouched()
            formCtrl.$submitted = false

    submitFeedback: ->
        formCtrl = angular.element(@$element[0].querySelector('form[name="feedbackForm"]')).controller('form')
        if formCtrl? and formCtrl.$invalid
            formCtrl.$setSubmitted()
            return
        @loading = true
        @error = null
        payload = {
            user_story: @$scope.$parent?.item?.id
            project: @$scope.$parent?.item?.project
            feedback_text: @feedbackText
            rating: @selectedRating
        }

        if @editingFeedback?
            @TaskFeedbacksService.updateFeedback(@editingFeedback, payload)
                .then (response) =>
                    @loading = false
                    @closeFeedbackModal()
                    @fetchFeedbacks()
                , (error) =>
                    @loading = false
                    @error = error?.error or @translate.instant('TASK_FEEDBACK.GENERIC_ERROR')
        else
            @TaskFeedbacksService.createFeedback(payload)
                .then (response) =>
                    @loading = false
                    @closeFeedbackModal()
                    @fetchFeedbacks()
                , (error) =>
                    @loading = false
                    @error = error?.error or @translate.instant('TASK_FEEDBACK.GENERIC_ERROR')

    deleteFeedback: ->
        return unless @editingFeedback?
        @loading = true
        @TaskFeedbacksService.deleteFeedback(@editingFeedback)
            .then (response) =>
                @loading = false
                @closeFeedbackModal()
                @fetchFeedbacks()
            , (error) =>
                @loading = false
                @error = error?.error or @translate.instant('TASK_FEEDBACK.GENERIC_ERROR')


angular.module("taigaComponents").controller("TaskFeedbacksController", TaskFeedbacksController)
