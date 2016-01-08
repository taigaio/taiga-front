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


ImportProjectButtonDirective = ($rs, $confirm, $location, $navUrls, $translate) ->
    link = ($scope, $el, $attrs) ->
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
                loader.stop()
                errorMsg = $translate.instant("PROJECT.IMPORT.ERROR")

                if result.status == 429  # TOO MANY REQUESTS
                    errorMsg = $translate.instant("PROJECT.IMPORT.ERROR_TOO_MANY_REQUEST")
                else if result.data?._error_message
                    errorMsg = $translate.instant("PROJECT.IMPORT.ERROR_MESSAGE", {error_message: result.data._error_message})
                $confirm.notify("error", errorMsg)

            loader.start()
            $rs.projects.import(file, loader.update).then(onSuccess, onError)

    return {link: link}

module.directive("tgImportProjectButton", ["$tgResources", "$tgConfirm", "$location", "$tgNavUrls", "$translate",
                                           ImportProjectButtonDirective])
