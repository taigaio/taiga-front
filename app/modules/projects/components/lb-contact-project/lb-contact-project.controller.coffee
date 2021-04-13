class ContactProjectLbController
    @.$inject = [
        "lightboxService",
        "tgResources",
        "$tgConfirm",
    ]

    constructor: (@lightboxService, @rs, @confirm) ->
        @.contact = {}

    contactProject: () ->
        project = @.project.get('id')
        message = @.contact.message

        promise = @rs.projects.contactProject(project, message)
        @.sendingFeedback = true
        promise.then  =>
            @lightboxService.closeAll()
            @.sendingFeedback = false
            @confirm.notify("success")

angular.module("taigaProjects").controller("ContactProjectLbCtrl", ContactProjectLbController)
