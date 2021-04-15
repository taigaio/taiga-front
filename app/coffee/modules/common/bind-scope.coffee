###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
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
