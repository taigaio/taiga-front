###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: projects/create/import/import-project.service.coffee
###

class ImportProjectService extends taiga.Service
    @.$inject = [
        'tgCurrentUserService',
        '$tgAuth',
        'tgLightboxFactory',
        '$translate',
        '$tgConfirm',
        '$location',
        '$tgNavUrls'
    ]

    constructor: (@currentUserService, @tgAuth, @lightboxFactory, @translate, @confirm, @location, @tgNavUrls) ->

    importPromise: (promise) ->
        return promise.then(@.importSuccess.bind(this), @.importError.bind(this))

    importSuccess: (result) ->
        promise = @currentUserService.loadProjects()
        promise.then () =>
            if result.status == 202 # Async mode
                title = @translate.instant('PROJECT.IMPORT.ASYNC_IN_PROGRESS_TITLE')
                message = @translate.instant('PROJECT.IMPORT.ASYNC_IN_PROGRESS_MESSAGE')
                @location.path(@tgNavUrls.resolve('home'))
                @confirm.success(title, message)
            else # result.status == 201 # Sync mode
                ctx = {project: result.data.slug}
                @location.path(@tgNavUrls.resolve('project-admin-project-profile-details', ctx))
                msg = @translate.instant('PROJECT.IMPORT.SYNC_SUCCESS')
                @confirm.notify('success', msg)
        return promise

    importError: (result) ->
        promise = @tgAuth.refresh()
        promise.then () =>
            restrictionError = @.getRestrictionError(result)

            if restrictionError
                @lightboxFactory.create('tg-lb-import-error', {
                    class: 'lightbox lightbox-import-error'
                }, restrictionError)

            else
                errorMsg = @translate.instant("PROJECT.IMPORT.ERROR")

                if result.status == 429  # TOO MANY REQUESTS
                    errorMsg = @translate.instant("PROJECT.IMPORT.ERROR_TOO_MANY_REQUEST")
                else if result.data?._error_message
                    errorMsg = @translate.instant("PROJECT.IMPORT.ERROR_MESSAGE", {error_message: result.data._error_message})

                @confirm.notify("error", errorMsg)
        return promise

    getRestrictionError: (result) ->
        if result.headers
            errorKey = ''

            user = @currentUserService.getUser()
            maxMemberships = null

            if result.headers.isPrivate
                privateError = !@currentUserService.canCreatePrivateProjects().valid

                if user.get('max_memberships_private_projects') != null && result.headers.memberships >= user.get('max_memberships_private_projects')
                    membersError = true
                else
                    membersError = false

                if privateError && membersError
                    errorKey = 'private-space-members'
                    maxMemberships = user.get('max_memberships_private_projects')
                else if privateError
                    errorKey = 'private-space'
                else if membersError
                    errorKey = 'private-members'
                    maxMemberships = user.get('max_memberships_private_projects')

            else
                publicError = !@currentUserService.canCreatePublicProjects().valid

                if user.get('max_memberships_public_projects') != null && result.headers.memberships >= user.get('max_memberships_public_projects')
                    membersError = true
                else
                    membersError = false

                if publicError && membersError
                    errorKey = 'public-space-members'
                    maxMemberships = user.get('max_memberships_public_projects')
                else if publicError
                    errorKey = 'public-space'
                else if membersError
                    errorKey = 'public-members'
                    maxMemberships = user.get('max_memberships_public_projects')

            if !errorKey
                return false

            return {
                key: errorKey,
                values: {
                    max_memberships: maxMemberships,
                    members: result.headers.memberships
                }
            }
        else
            return false

angular.module("taigaProjects").service("tgImportProjectService", ImportProjectService)
