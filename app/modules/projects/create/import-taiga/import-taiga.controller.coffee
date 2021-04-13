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
