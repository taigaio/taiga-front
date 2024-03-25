###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
    "tgAsanaImportResource",
    "tgOnPremiseResource"
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
