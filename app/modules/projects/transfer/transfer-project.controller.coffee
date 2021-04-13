module = angular.module('taigaProjects')

class TransferProject
    @.$inject = [
        "$routeParams",
        "tgProjectsService"
        "tgProjectService"
        "$location",
        "$tgAuth",
        "tgCurrentUserService",
        "$tgNavUrls",
        "$translate",
        "$tgConfirm",
        "tgErrorHandlingService"
    ]

    constructor: (@routeParams, @projectsService, @projectService, @location, @authService, @currentUserService, @navUrls, @translate, @confirmService, @errorHandlingService) ->

    initialize: () ->
        @.projectId = @.project.get("id")
        @.token = @routeParams.token
        @.showAddComment = false
        return @._refreshUserData()

    _validateToken: () ->
        return @projectsService.transferValidateToken(@.projectId, @.token).then null, (data, status) =>
            @errorHandlingService.notfound()

    _refreshUserData: () ->
        return @authService.refresh().then () =>
            @._validateToken()
            @._setProjectData()
            @._checkOwnerData()

    _setProjectData: () ->
        @.canBeOwnedByUser = @currentUserService.canOwnProject(@.project)

    _checkOwnerData: () ->
        currentUser = @currentUserService.getUser()
        if(@.project.get('is_private'))
            @.ownerMessage = 'ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PRIVATE'
            @.maxProjects = currentUser.get('max_private_projects')
            if @.maxProjects == null
                @.maxProjects = @translate.instant('ADMIN.PROJECT_TRANSFER.UNLIMITED_PROJECTS')
            @.currentProjects = currentUser.get('total_private_projects')
            maxMemberships = currentUser.get('max_memberships_private_projects')

        else
            @.ownerMessage = 'ADMIN.PROJECT_TRANSFER.OWNER_MESSAGE.PUBLIC'
            @.maxProjects = currentUser.get('max_public_projects')
            if @.maxProjects == null
                @.maxProjects = @translate.instant('ADMIN.PROJECT_TRANSFER.UNLIMITED_PROJECTS')
            @.currentProjects = currentUser.get('total_public_projects')
            maxMemberships = currentUser.get('max_memberships_public_projects')

        @.validNumberOfMemberships = maxMemberships == null || @.project.get('total_memberships') <= maxMemberships

    transferAccept: (token, reason) ->
        @.loadingAccept = true
        return @projectsService.transferAccept(@.project.get("id"), token, reason).then () =>
            @projectService.fetchProject().then () =>
                newUrl = @navUrls.resolve("project-admin-project-profile-details", {
                    project: @.project.get("slug")
                })
                @.loadingAccept = false
                @location.path(newUrl)

                @confirmService.notify("success", @translate.instant("ADMIN.PROJECT_TRANSFER.ACCEPTED_PROJECT_OWNERNSHIP"), '', 5000)
                return

    transferReject: (token, reason) ->
        @.loadingReject = true
        return @projectsService.transferReject(@.project.get("id"), token, reason).then () =>
            newUrl = @navUrls.resolve("home", {
                project: @project.get("slug")
            })
            @.loadingReject = false
            @location.path(newUrl)
            @confirmService.notify("success", @translate.instant("ADMIN.PROJECT_TRANSFER.REJECTED_PROJECT_OWNERNSHIP"), '', 5000)

            return

    addComment: () ->
        @.showAddComment = true

    hideComment: () ->
        @.showAddComment = false
        @.reason = ''


module.controller("TransferProjectController", TransferProject)
