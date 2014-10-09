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
    lng: "en"
}

class I18nService extends taiga.Service
    constructor: (@rootscope, localesEn) ->
        @.options = _.clone(defaults, true)
        @.options.resStore = {
            en: { app: localesEn }
        }

    setLanguage: (language) ->
        i18n.setLng(language)
        @rootscope.currentLang = language
        @rootscope.$broadcast("i18n:changeLang", language)

    initialize: ->
        i18n.init(@.options)
        @rootscope.t = i18n.t

    t: (path, opts) ->
        return i18n.t(path, opts)


I18nDirective = ($rootscope, $i18n) ->
    link = ($scope, $el, $attrs) ->
        values = $attrs.tr.split(",")
        options = $attrs.trOpts or '{}'
        opts = $scope.$eval(options)

        for v in values
            if v.indexOf(":") == -1
                $el.html(_.escape($i18n.t(v, opts)))
            else
                [ns, v] = v.split(":")
                $el.attr(ns, _.escape($i18n.t(v, opts)))

    return {
        link: link
        restrict: "A"
        scope: false
    }


module = angular.module("taigaBase")
module.service("$tgI18n", ["$rootScope", "localesEn", I18nService])
module.directive("tr", ["$rootScope", "$tgI18n", I18nDirective])
