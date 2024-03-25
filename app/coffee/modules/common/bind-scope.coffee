###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

module = angular.module("taigaCommon")

BindScope = (config) ->
    if !config.debugInfo
        jQuery.fn.scope = () -> this.data('scope')

    link = ($scope, $el) ->
        if !config.debugInfo
            $el
                .data('scope', $scope)
                .addClass('tg-scope')

    return {link: link}

module.directive("tgBindScope", ["$tgConfig", BindScope])
