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
# File: resources/resources.coffee
###

services = [
    "tgProjectsResources",
    "tgUserResources",
    "tgUsersResources",
    "tgUserstoriesResource",
    "tgTasksResource",
    "tgIssuesResource",
    "tgExternalAppsResource",
    "tgAttachmentsResource",
    "tgStatsResource",
    "tgHistory",
    "tgEpicsResource",
    "tgTrelloImportResource",
    "tgJiraImportResource",
    "tgGithubImportResource",
    "tgAsanaImportResource"
]

Resources = ($injector) ->
    for serviceName in services
        serviceFn = $injector.get(serviceName)

        service = $injector.invoke(serviceFn)

        for serviceProperty in Object.keys(service)
            if @[serviceProperty]
                console.warn("repeated resource " + serviceProperty)

            @[serviceProperty] = service[serviceProperty]

    return @


Resources.$inject = ["$injector"]

angular.module("taigaResources2").service("tgResources", Resources)
