###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

AutoSelectDirective = ($timeout) ->
    return {
        link: (scope, elm) ->
            $timeout () -> elm[0].select()
    }

AutoSelectDirective.$inject = [
    '$timeout'
]

angular.module("taigaComponents").directive("tgAutoSelect", AutoSelectDirective)
