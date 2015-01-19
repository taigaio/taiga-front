###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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


ImportProjectButtonDirective = ($rs, $confirm, $location, $navUrls) ->
    link = ($scope, $el, $attrs) ->
        $el.on "click", ".import-project-button", (event) ->
            event.preventDefault()
            $el.find("input.import-file").val("")
            $el.find("input.import-file").trigger("click")

        $el.on "change", "input.import-file", (event) ->
            event.preventDefault()
            file = event.target.files[0]
            return if not file

            loader = $confirm.loader("Uploading dump file")

            onSuccess = (result) ->
                loader.stop()
                if result.status == 202 # Async mode
                    title = "Our Oompa Loompas are importing your project" # TODO: i18n
                    message = "This process could take a few minutes <br/> We will send you
                               an email when ready" # TODO: i18n
                    $confirm.success(title, message)

                else # result.status == 201 # Sync mode
                    ctx = {project: result.data.slug}
                    $location.path($navUrls.resolve("project-admin-project-profile-details", ctx))
                    $confirm.notify("success", "Your project has been imported successfuly.") # TODO: i18n

            onError = (result) ->
                loader.stop()
                console.log "Error", result
                errorMsg = "Our oompa loompas have some problems importing your dump data.
                            Please try again. " # TODO: i18n

                if result.status == 429  # TOO MANY REQUESTS
                    errorMsg = "Sorry, our oompa loompas are very busy right now.
                                Please try again in a few minutes. " # TODO: i18n
                else if result.data?._error_message
                    errorMsg = "Our oompa loompas have some problems importing your dump data:
                                #{result.data._error_message}" # TODO: i18n

                $confirm.notify("error", errorMsg)

            loader.start()
            $rs.projects.import(file, loader.update).then(onSuccess, onError)

    return {link: link}

module.directive("tgImportProjectButton", ["$tgResources", "$tgConfirm", "$location", "$tgNavUrls",
                                           ImportProjectButtonDirective])
