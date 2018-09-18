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
# File: modules/resources/user-settings.coffee
###


taiga = @.taiga
sizeFormat = @.taiga.sizeFormat


resourceProvider = ($config, $repo, $http, $urls, $q) ->
    service = {}

    service.changeAvatar = (file) ->
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
        data.append('avatar', file)
        options = {
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        }
        url = "#{$urls.resolve("users")}/change_avatar"
        return $http.post(url, data, {}, options)

    service.removeAvatar = () ->
        url = "#{$urls.resolve("users")}/remove_avatar"
        return $http.post(url)

    service.changePassword = (currentPassword, newPassword) ->
        url = "#{$urls.resolve("users")}/change_password"
        data = {
            current_password: currentPassword
            password: newPassword
        }
        return $http.post(url, data)

    return (instance) ->
        instance.userSettings = service


module = angular.module("taigaResources")
module.factory("$tgUserSettingsResourcesProvider", ["$tgConfig", "$tgRepo", "$tgHttp", "$tgUrls", "$q",
                                                    resourceProvider])
