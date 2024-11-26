###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

$translateMissingTranslationHandlerLog = ($log) ->
  (translationId) ->
    # $log.warn 'Translation for ' + translationId + ' doesn\'t exist'
    return

$translateMissingTranslationHandlerLog.$inject = [ '$log' ]

angular.module('pascalprecht.translate').factory '$translateMissingTranslationHandlerLog', $translateMissingTranslationHandlerLog

$translateMissingTranslationHandlerLog.displayName = '$translateMissingTranslationHandlerLog'
