###
# Copyright (C) 2014-2016 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2016 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2016 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2016 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2016 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2016 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/common/importer.coffee
###

module = angular.module("taigaCommon")


ImportProjectButtonDirective = ($rs, $confirm, $location, $navUrls, $translate, $lightboxFactory, currentUserService, $tgAuth) ->
    link = ($scope, $el, $attrs) ->
        getRestrictionError = (result) ->
            if result.headers
                errorKey = ''

                user = currentUserService.getUser()
                maxMemberships = 0

                if result.headers.isPrivate
                    privateError = !currentUserService.canCreatePrivateProjects().valid
                    maxMemberships = null

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
                    publicError = !currentUserService.canCreatePublicProjects().valid

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

                return {
                    key: errorKey,
                    values: {
                        max_memberships: maxMemberships,
                        members: result.headers.memberships
                    }
                }
            else
                return false

        $el.on "click", ".import-project-button", (event) ->
            event.preventDefault()
            $el.find("input.import-file").val("")
            $el.find("input.import-file").trigger("click")

        $el.on "change", "input.import-file", (event) ->
            event.preventDefault()
            file = event.target.files[0]
            return if not file

            loader = $confirm.loader($translate.instant("PROJECT.IMPORT.UPLOADING_FILE"))

            onSuccess = (result) ->
                currentUserService.loadProjects().then () ->
                    loader.stop()

                    if result.status == 202 # Async mode
                        title = $translate.instant("PROJECT.IMPORT.ASYNC_IN_PROGRESS_TITLE")
                        message = $translate.instant("PROJECT.IMPORT.ASYNC_IN_PROGRESS_MESSAGE")
                        $confirm.success(title, message)

                    else # result.status == 201 # Sync mode
                        ctx = {project: result.data.slug}
                        $location.path($navUrls.resolve("project-admin-project-profile-details", ctx))
                        msg = $translate.instant("PROJECT.IMPORT.SYNC_SUCCESS")
                        $confirm.notify("success", msg)

            onError = (result) ->
                $tgAuth.refresh().then () ->
                    restrictionError = getRestrictionError(result)

                    loader.stop()

                    if restrictionError
                        $lightboxFactory.create('tg-lb-import-error', {
                            class: 'lightbox lightbox-import-error'
                        }, restrictionError)

                    else
                        errorMsg = $translate.instant("PROJECT.IMPORT.ERROR")

                        if result.status == 429  # TOO MANY REQUESTS
                            errorMsg = $translate.instant("PROJECT.IMPORT.ERROR_TOO_MANY_REQUEST")
                        else if result.data?._error_message
                            errorMsg = $translate.instant("PROJECT.IMPORT.ERROR_MESSAGE", {error_message: result.data._error_message})
                        $confirm.notify("error", errorMsg)

            loader.start()
            $rs.projects.import(file, loader.update).then(onSuccess, onError)

    return {link: link}

module.directive("tgImportProjectButton",
["$tgResources", "$tgConfirm", "$location", "$tgNavUrls", "$translate", "tgLightboxFactory", "tgCurrentUserService", "$tgAuth",
                                           ImportProjectButtonDirective])

LbImportErrorDirective = (lightboxService) ->
    link = (scope, el, attrs) ->
        lightboxService.open(el)

        scope.close = () ->
            lightboxService.close(el)
            return

    return {
        templateUrl: "common/lightbox/lightbox-import-error.html",
        link: link
    }

LbImportErrorDirective.$inject = ["lightboxService"]

module.directive("tgLbImportError", LbImportErrorDirective)
