###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
