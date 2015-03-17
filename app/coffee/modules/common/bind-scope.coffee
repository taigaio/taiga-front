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
