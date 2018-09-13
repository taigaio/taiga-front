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
# File: projects/create/import-taiga/import-taiga.controller.coffee
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

        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        promise = @rs.projects.import(file, loader.update)

        @importProjectService.importPromise(promise).finally () => loader.stop()

        return

angular.module("taigaProjects").controller("ImportTaigaCtrl", ImportTaigaController)
