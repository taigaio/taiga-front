###
# Copyright (C) 2014-2017 Andrey Antukh <niwi@niwi.nz>
# Copyright (C) 2014-2017 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014-2017 David Barragán Merino <bameda@dbarragan.com>
# Copyright (C) 2014-2017 Alejandro Alonso <alejandro.alonso@kaleidos.net>
# Copyright (C) 2014-2017 Juan Francisco Alcántara <juanfran.alcantara@kaleidos.net>
# Copyright (C) 2014-2017 Xavi Julian <xavier.julian@kaleidos.net>
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
# File: modules/resources/projects.coffee
###


taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($config, $repo, $http, $urls, $auth, $q, $translate) ->
    service = {}

    service.get = (projectId) ->
        return $repo.queryOne("projects", projectId)

    service.getBySlug = (projectSlug) ->
        return $repo.queryOne("projects", "by_slug?slug=#{projectSlug}")

    service.list = (filters) ->
        params = {"order_by": "user_order"}
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("projects", params)

    service.listByMember = (memberId) ->
        params = {"member": memberId, "order_by": "user_order"}
        return $repo.queryMany("projects", params)

    service.templates = ->
        return $repo.queryMany("project-templates")

    service.usersList = (projectId) ->
        params = {"project": projectId}
        return $repo.queryMany("users", params)

    service.rolesList = (projectId) ->
        params = {"project": projectId}
        return $repo.queryMany("roles", params)

    service.stats = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/stats")

    service.bulkUpdateOrder = (bulkData) ->
        url = $urls.resolve("bulk-update-projects-order")
        return $http.post(url, bulkData)

    service.regenerate_epics_csv_uuid = (projectId) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/regenerate_epics_csv_uuid"
        return $http.post(url)

    service.regenerate_userstories_csv_uuid = (projectId) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/regenerate_userstories_csv_uuid"
        return $http.post(url)

    service.regenerate_tasks_csv_uuid = (projectId) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/regenerate_tasks_csv_uuid"
        return $http.post(url)

    service.regenerate_issues_csv_uuid = (projectId) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/regenerate_issues_csv_uuid"
        return $http.post(url)

    service.leave = (projectId) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/leave"
        return $http.post(url)

    service.memberStats = (projectId) ->
        return $repo.queryOneRaw("projects", "#{projectId}/member_stats")

    service.tagsColors = (projectId) ->
        return $repo.queryOne("projects", "#{projectId}/tags_colors")

    service.deleteTag = (projectId, tag) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/delete_tag"
        return $http.post(url, {tag: tag})

    service.createTag = (projectId, tag, color) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/create_tag"
        data = {}
        data.tag = tag
        data.color = null
        if color
            data.color = color
        return $http.post(url, data)

    service.editTag = (projectId, from_tag, to_tag, color) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/edit_tag"
        data = {}
        data.from_tag = from_tag
        if to_tag
            data.to_tag = to_tag
        data.color = null
        if color
            data.color = color
        return $http.post(url, data)

    service.mixTags = (projectId, to_tag, from_tags) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/mix_tags"
        return $http.post(url, {to_tag: to_tag, from_tags: from_tags})

    service.export = (projectId) ->
        url = "#{$urls.resolve("exporter")}/#{projectId}"
        return $http.get(url)

    service.import = (file, statusUpdater) ->
        defered = $q.defer()

        maxFileSize = $config.get("maxUploadFileSize", null)
        if maxFileSize and file.size > maxFileSize
            errorMsg = $translate.instant("PROJECT.IMPORT.ERROR_MAX_SIZE_EXCEEDED", {
                fileName: file.name
                fileSize: sizeFormat(file.size)
                maxFileSize: sizeFormat(maxFileSize)
            })

            response = {
                status: 413,
                data: _error_message: errorMsg
            }
            defered.reject(response)
            return defered.promise

        uploadProgress = (evt) =>
            percent = Math.round((evt.loaded / evt.total) * 100)
            message = $translate.instant("PROJECT.IMPORT.UPLOAD_IN_PROGRESS_MESSAGE", {
                uploadedSize: sizeFormat(evt.loaded)
                totalSize: sizeFormat(evt.total)
            })
            statusUpdater("in-progress", null, message, percent)

        uploadComplete = (evt) =>
            statusUpdater("done",
                          $translate.instant("PROJECT.IMPORT.TITLE"),
                          $translate.instant("PROJECT.IMPORT.DESCRIPTION"))

        uploadFailed = (evt) =>
            statusUpdater("error")

        complete = (evt) =>
            response = {}
            try
                response.data = JSON.parse(evt.target.responseText)
            catch
                response.data = {}
            response.status = evt.target.status
            if evt.target.getResponseHeader('Taiga-Info-Project-Is-Private')
                response.headers = {
                    isPrivate: evt.target.getResponseHeader('Taiga-Info-Project-Is-Private') == 'True',
                    memberships: parseInt(evt.target.getResponseHeader('Taiga-Info-Project-Memberships'))
                }
            defered.resolve(response) if response.status in [201, 202]
            defered.reject(response)

        failed = (evt) =>
            defered.reject("fail")

        data = new FormData()
        data.append('dump', file)

        xhr = new XMLHttpRequest()
        xhr.upload.addEventListener("progress", uploadProgress, false)
        xhr.upload.addEventListener("load", uploadComplete, false)
        xhr.upload.addEventListener("error", uploadFailed, false)
        xhr.upload.addEventListener("abort", uploadFailed, false)
        xhr.addEventListener("load", complete, false)
        xhr.addEventListener("error", failed, false)

        xhr.open("POST", $urls.resolve("importer"))
        xhr.setRequestHeader("Authorization", "Bearer #{$auth.getToken()}")
        xhr.setRequestHeader('Accept', 'application/json')
        xhr.send(data)

        return defered.promise

    service.changeLogo = (projectId, file) ->
        maxFileSize = $config.get("maxUploadFileSize", null)
        if maxFileSize and file.size > maxFileSize
            response = {
                status: 413,
                data: _error_message: "'#{file.name}' (#{sizeFormat(file.size)}) is too heavy for our oompa
                                       loompas, try it with a smaller than (#{sizeFormat(maxFileSize)})"
            }
            defered = $q.defer()
            defered.reject(response)
            return defered.promise

        data = new FormData()
        data.append('logo', file)
        options = {
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        }
        url = "#{$urls.resolve("projects")}/#{projectId}/change_logo"
        return $http.post(url, data, {}, options)

    service.removeLogo = (projectId) ->
        url = "#{$urls.resolve("projects")}/#{projectId}/remove_logo"
        return $http.post(url)

    return (instance) ->
        instance.projects = service


module = angular.module("taigaResources")
module.factory("$tgProjectsResourcesProvider", ["$tgConfig", "$tgRepo", "$tgHttp", "$tgUrls", "$tgAuth",
                                                "$q", "$translate", resourceProvider])
