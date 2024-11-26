###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

bindOnce = @.taiga.bindOnce

# Escape Html bind once directive
BindOnceBindDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoBind, (val) ->
            $el.text(val)

    return {link:link}

# Html bind once directive
BindOnceHtmlDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoHtml, (val) ->
            $el.html(val)

    return {link:link}

# Object reference bind once helper.
BindOnceRefDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoRef, (val) ->
            $el.html("##{val} ")
    return {link:link}

# Object src bind once helper.
BindOnceSrcDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoSrc, (val) ->
            $el.attr("src", val)
    return {link:link}

# Object href bind once helper.
BindOnceHrefDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoHref, (val) ->
            $el.attr("href", val)
    return {link:link}

# Object alt bind once helper.
BindOnceAltDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoAlt, (val) ->
            $el.attr("alt", val)
    return {link:link}

# Object title bind once helper.
BindOnceTitleDirective = ->
    link = ($scope, $el, $attrs) ->
        bindOnce $scope, $attrs.tgBoTitle, (val) ->
            $el.attr("title", val)
    return {link:link}

BindTitleDirective = ->
    link = ($scope, $el, $attrs) ->
        $scope.$watch $attrs.tgTitleHtml, (val) ->
            $el.attr("title", val) if val?

    return {link:link}

BindHtmlDirective = ->
    link = ($scope, $el, $attrs) ->
        $scope.$watch $attrs.tgBindHtml, (val) ->
            $el.html(val) if val?

    return {link:link}

module = angular.module("taigaBase")
module.directive("tgBoBind", BindOnceBindDirective)
module.directive("tgBoHtml", BindOnceHtmlDirective)
module.directive("tgBoRef", BindOnceRefDirective)
module.directive("tgBoSrc", BindOnceSrcDirective)
module.directive("tgBoHref", BindOnceHrefDirective)
module.directive("tgBoAlt", BindOnceAltDirective)
module.directive("tgBoTitle", BindOnceTitleDirective)
module.directive("tgBindTitle", BindTitleDirective)
module.directive("tgBindHtml", BindHtmlDirective)
