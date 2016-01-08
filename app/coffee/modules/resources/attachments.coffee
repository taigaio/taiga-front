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
# File: modules/resources/attachments.coffee
###


taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($rootScope, $config, $urls, $model, $repo, $auth, $q) ->
    service = {}

    service.list = (urlName, objectId, projectId) ->
        params = {object_id: objectId, project: projectId}
        return $repo.queryMany(urlName, params)

    service.create = (urlName, projectId, objectId, file) ->
        defered = $q.defer()

        if file is undefined
            defered.reject(null)
            return defered.promise

        maxFileSize = $config.get("maxUploadFileSize", null)
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
                    data = JSON.parse(evt.target.responseText)
                catch
                    data = {}

                if status >= 200 and status < 400
                    model = $model.make_model(urlName, data)
                    defered.resolve(model)
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

        xhr = new XMLHttpRequest()
        xhr.upload.addEventListener("progress", uploadProgress, false)
        xhr.addEventListener("load", uploadComplete, false)
        xhr.addEventListener("error", uploadFailed, false)

        xhr.open("POST", $urls.resolve(urlName))
        xhr.setRequestHeader("Authorization", "Bearer #{$auth.getToken()}")
        xhr.setRequestHeader('Accept', 'application/json')
        xhr.send(data)

        return defered.promise

    return (instance) ->
        instance.attachments = service


module = angular.module("taigaResources")
module.factory("$tgAttachmentsResourcesProvider", ["$rootScope", "$tgConfig", "$tgUrls", "$tgModel", "$tgRepo",
                                                   "$tgAuth", "$q", resourceProvider])
