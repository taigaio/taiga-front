class JiraImportProjectFormController
    @.$inject = [
        "tgCurrentUserService"
    ]

    constructor: (@currentUserService) ->
        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        @.projectForm = @.project.toJS()

        @.projectForm.is_private = false
        @.projectForm.keepExternalReference = false
        if @.projectForm.importer_type == "agile"
            @.projectForm.project_type = null
        else
            @.projectForm.project_type = "scrum"
        @.projectForm.create_subissues = true

        if !@.canCreatePublicProjects.valid && @.canCreatePrivateProjects.valid
            @.projectForm.is_private = true

    checkUsersLimit: () ->
        @.limitMembersPrivateProject = @currentUserService.canAddMembersPrivateProject(@.members.size)
        @.limitMembersPublicProject = @currentUserService.canAddMembersPublicProject(@.members.size)

    saveForm: () ->
        @.onSaveProjectDetails({project: Immutable.fromJS(@.projectForm)})

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid
        else
            return @.canCreatePublicProjects.valid

    isDisabled: () ->
        return !@.canCreateProject()

angular.module('taigaProjects').controller('JiraImportProjectFormCtrl', JiraImportProjectFormController)
