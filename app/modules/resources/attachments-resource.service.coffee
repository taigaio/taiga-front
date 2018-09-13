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
# File: resources/attachments-resource.service.coffee
###

taiga = @.taiga
sizeFormat = @.taiga.sizeFormat

Resource = (urlsService, http, config, $rootScope, $q, storage) ->
    service = {}

    service.list = (type, objectId, projectId) ->
        urlname = "attachments/#{type}"

        params = {object_id: objectId, project: projectId}
        httpOptions = {
            headers: {
                "x-disable-pagination": "1"
            }
        }

        url = urlsService.resolve(urlname)

        return http.get(url, params, httpOptions)
            .then (result) -> Immutable.fromJS(result.data)

    service.delete = (type, id) ->
        urlname = "attachments/#{type}"

        url = urlsService.resolve(urlname) + "/#{id}"

        return http.delete(url)

    service.patch = (type, id, patch) ->
        urlname = "attachments/#{type}"

        url = urlsService.resolve(urlname) + "/#{id}"

        return http.patch(url, patch)

    service.create = (type, projectId, objectId, file, from_comment) ->
        urlname = "attachments/#{type}"

        url = urlsService.resolve(urlname)

        defered = $q.defer()

        if file is undefined
            defered.reject(null)
            return defered.promise

        maxFileSize = config.get("maxUploadFileSize", null)

        if maxFileSize and file.size > maxFileSize
            response = {
                status: 413,
                data: _error_message: "'#{file.name}' (#{sizeFormat(file.size)}) is too heavy for our oompa
                                       loompas, try it with a smaller than (#{sizeFormat(maxFileSize)})"
            }
            defered.reject(response)
            return defered.promise

        uploadProgress = (evt) =>
            $rootScope.$apply =>
                file.status = "in-progress"
                file.size = sizeFormat(evt.total)
                file.progressMessage = "upload #{sizeFormat(evt.loaded)} of #{sizeFormat(evt.total)}"
                file.progressPercent = "#{Math.round((evt.loaded / evt.total) * 100)}%"

        uploadComplete = (evt) =>
            $rootScope.$apply ->
                file.status = "done"

                status = evt.target.status
                try
                    attachment = JSON.parse(evt.target.responseText)
                catch
                    attachment = {}

                if status >= 200 and status < 400
                    attachment = Immutable.fromJS(attachment)
                    defered.resolve(attachment)
                else
                    response = {
                        status: status,
                        data: {_error_message: data['attached_file']?[0]}
                    }
                    defered.reject(response)

        uploadFailed = (evt) =>
            $rootScope.$apply ->
                file.status = "error"
                defered.reject("fail")

        data = new FormData()
        data.append("project", projectId)
        data.append("object_id", objectId)
        data.append("attached_file", file)
        data.append("from_comment", from_comment)

        xhr = new XMLHttpRequest()
        xhr.upload.addEventListener("progress", uploadProgress, false)
        xhr.addEventListener("load", uploadComplete, false)
        xhr.addEventListener("error", uploadFailed, false)

        token = storage.get('token')

        xhr.open("POST", url)
        xhr.setRequestHeader("Authorization", "Bearer #{token}")
        xhr.setRequestHeader('Accept', 'application/json')
        xhr.send(data)

        return defered.promise

    return () ->
        return {"attachments": service}

Resource.$inject = [
    "$tgUrls",
    "$tgHttp",
    "$tgConfig",
    "$rootScope",
    "$q",
    "$tgStorage"
]

module = angular.module("taigaResources2")
module.factory("tgAttachmentsResource", Resource)
