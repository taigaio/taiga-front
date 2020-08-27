
$translateMissingTranslationHandlerLog = ($log) ->
  (translationId) ->
    # $log.warn 'Translation for ' + translationId + ' doesn\'t exist'
    return

$translateMissingTranslationHandlerLog.$inject = [ '$log' ]

angular.module('pascalprecht.translate').factory '$translateMissingTranslationHandlerLog', $translateMissingTranslationHandlerLog

$translateMissingTranslationHandlerLog.displayName = '$translateMissingTranslationHandlerLog'
