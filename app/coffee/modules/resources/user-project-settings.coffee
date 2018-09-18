###
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
# File: modules/resources/user-project-settings.coffee
###

taiga = @.taiga

resourceProvider = ($repo, $http, $urls) ->
    service = {}

    service.get = (id) ->
        return $repo.queryOne("user-project-settings", id)

    service.list = (filters) ->
        params = _.extend({}, params, filters or {})
        return $repo.queryMany("user-project-settings", params)

    return (instance) ->
        instance.userProjectSettings = service


module = angular.module("taigaResources")
module.factory("$tgUserProjectSettingsResourcesProvider", ["$tgRepo", "$tgHttp", "$tgUrls", resourceProvider])
