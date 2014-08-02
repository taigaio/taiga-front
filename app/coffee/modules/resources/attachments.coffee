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
# File: modules/resources/attachments.coffee
###


taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($rootScope, $urls, $model, $repo, $auth, $q) ->
    service = {}

    service.list = (urlName, objectId) ->
        params = {object_id: objectId}
        return $repo.queryMany(urlName, params)

    service.create = (urlName, projectId, objectId, file) ->
        defered = $q.defer()

        if file is undefined
            defered.reject(null)
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
                try
                    data = JSON.parse(evt.target.responseText)
                catch
                    data = {}

                model =  $model.make_model(urlName, data)
                defered.resolve(model)

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
module.factory("$tgAttachmentsResourcesProvider", ["$rootScope", "$tgUrls", "$tgModel", "$tgRepo", "$tgAuth",
                                                   "$q", resourceProvider])
