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
# File: utils.coffee
###

bindOnce = (scope, attr, continuation) =>
    val = scope.$eval(attr)
    if val != undefined
        return continuation(val)

    delBind = null
    delBind = scope.$watch attr, (val) ->
        return if val is undefined
        continuation(val)
        delBind() if delBind


mixOf = (base, mixins...) ->
    class Mixed extends base

    for mixin in mixins by -1 #earlier mixins override later ones
        for name, method of mixin::
            Mixed::[name] = method
    Mixed


trim = (data, char) ->
    return _.str.trim(data, char)


toggleText = (element, texts) ->
    nextTextPosition = element.data('nextTextPosition')
    nextTextPosition = 0 if not nextTextPosition? or nextTextPosition >= texts.length
    text = texts[nextTextPosition]
    element.data('nextTextPosition', nextTextPosition + 1)
    element.text(text)


groupBy = (coll, pred) ->
    result = {}
    for item in coll
        result[pred(item)] = item

    return result


timeout = (wait, continuation) ->
    return window.setTimeout(continuation, wait)


scopeDefer = (scope, func) ->
    _.defer =>
        scope.$apply(func)


toString = (value) ->
    if _.isNumber(value)
        return value + ""
    else if _.isString(value)
        return value
    else if _.isPlainObject(value)
        return JSON.stringify(value)
    else if _.isUndefined(value)
        return ""
    return value.toString()


joinStr = (str, coll) ->
    return _.str.join(str, coll)


taiga = @.taiga
taiga.bindOnce = bindOnce
taiga.mixOf = mixOf
taiga.trim = trim
taiga.toggleText = toggleText
taiga.groupBy = groupBy
taiga.timeout = timeout
taiga.scopeDefer = scopeDefer
taiga.toString = toString
taiga.joinStr = joinStr
