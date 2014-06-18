###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
# File: modules/base/i18n.coffee
###

taiga = @.taiga
bindOnce = @.taiga.bindOnce

defaults = {
    ns: "app"
    fallbackLng: "en"
    async: false
}


class I18nService extends taiga.Service
    constructor: (@rootscope, @localeEn) ->

    setLanguage: (language) ->
        options = _.clone(defaults, true)
        i18n.setLng(language, options)

        @rootscope.currentLang = language
        @rootscope.$broadcast("i18n:changeLang", language)

    initialize: (defaultLang="en") ->
        options = _.clone(defaults, true)
        options.lng = defaultLang
        options.resStore = {
            en: { app: @localeEn }
        }

        i18n.init(options)
        @rootscope.t = i18n.t


I18nDirective = ($rootscope, $i18n) ->
    link = ($scope, $el, $attrs) ->
        values = $attrs.tgI18n.split(",")
        options = $attrs.tgI18nOptions or '{}'

        applyTranslation = ->
            opts = $scope.$eval(options)

            for v in values
                if v.indexOf(":") == -1
                    $el.html($scope.t(v, opts))
                else
                    [ns, v] = v.split(":")
                    $el.attr(ns, $scope.t(v, opts))

        bindOnce($scope, "t", applyTranslation)
        $scope.$on("i18n:changeLang", applyTranslation)

    return {link: link}


module = angular.module("taigaBase")
module.service("$tgI18n", ["$rootScope", "localesEnglish", I18nService])
module.directive("tgI18n", ["$rootScope", "$tgI18n", I18nDirective])
