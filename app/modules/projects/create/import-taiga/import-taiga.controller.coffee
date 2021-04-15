###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ImportTaigaController
    @.$inject = [
        '$tgConfirm',
        '$tgResources',
        'tgImportProjectService',
        '$translate',
        '$tgAnalytics',
    ]

    constructor: (@confirm, @rs, @importProjectService, @translate, @analytics) ->

    importTaiga: (files) ->
        @analytics.trackEvent("import", "taiga", "Start import from taiga", 1)

        file = files[0]

        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'),
            @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        promise = @rs.projects.import(file, loader.update)
        @importProjectService.importPromise(promise).finally () -> loader.stop()

        return

angular.module("taigaProjects").controller("ImportTaigaCtrl", ImportTaigaController)
