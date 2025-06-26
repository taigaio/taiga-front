###
# Directive for task feedback, modeled after attachments-full
###
bindOnce = @.taiga.bindOnce

TaskFeedbacksDirective = () ->
 
    return {
        scope: true,
        bindToController: {
            type: "@",
            objId: "=",
            projectId: "=",
            editPermission: "@"
        },
        controller: "TaskFeedbacksController",
        controllerAs: "vm",
        templateUrl: "components/task-feedbacks/task-feedbacks.html",
    }

TaskFeedbacksDirective.$inject = []

angular.module("taigaComponents").directive("tgTaskFeedbacks", TaskFeedbacksDirective)
