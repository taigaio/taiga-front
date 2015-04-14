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

nl2br = (str) =>
    breakTag = '<br />'
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2')

bindMethods = (object) =>
    dependencies = _.keys(object)

    methods = []

    _.forIn object, (value, key) =>
        if key not in dependencies
            methods.push(key)

    _.bindAll(object, methods)

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


slugify = (data) ->
    return _.str.slugify(data)


unslugify = (data) ->
    if data
        return _.str.capitalize(data.replace(/-/g, ' '))
    return data


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


cancelTimeout = (timeoutVar) ->
    window.clearTimeout(timeoutVar)


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


debounce = (wait, func) ->
    return _.debounce(func, wait, {leading: true, trailing: false})


debounceLeading = (wait, func) ->
    return _.debounce(func, wait, {leading: false, trailing: true})


startswith = (str1, str2) ->
    return _.str.startsWith(str1, str2)


sizeFormat = (input, precision=1) ->
    if isNaN(parseFloat(input)) or not isFinite(input)
        return "-"

    if input == 0
        return "0 bytes"

    units = ["bytes", "KB", "MB", "GB", "TB", "PB"]
    number = Math.floor(Math.log(input) / Math.log(1024))
    if number > 5
        number = 5
    size = (input / Math.pow(1024, number)).toFixed(precision)
    return  "#{size} #{units[number]}"

stripTags = (str, exception) ->
    if exception
        pattern = new RegExp('<(?!' + exception + '\s*\/?)[^>]+>', 'gi')
        return String(str).replace(pattern, '')
    else
        return String(str).replace(/<\/?[^>]+>/g, '')

replaceTags = (str, tags, replace) ->
    # open tag
    pattern = new RegExp('<(' + tags + ')>', 'gi')
    str = str.replace(pattern, '<' + replace + '>')

    # close tag
    pattern = new RegExp('<\/(' + tags + ')>', 'gi')
    str = str.replace(pattern, '</' + replace + '>')

    return str

taiga = @.taiga
taiga.nl2br = nl2br
taiga.bindMethods = bindMethods
taiga.bindOnce = bindOnce
taiga.mixOf = mixOf
taiga.trim = trim
taiga.slugify = slugify
taiga.unslugify = unslugify
taiga.toggleText = toggleText
taiga.groupBy = groupBy
taiga.timeout = timeout
taiga.cancelTimeout = cancelTimeout
taiga.scopeDefer = scopeDefer
taiga.toString = toString
taiga.joinStr = joinStr
taiga.debounce = debounce
taiga.debounceLeading = debounceLeading
taiga.startswith = startswith
taiga.sizeFormat = sizeFormat
taiga.stripTags = stripTags
taiga.replaceTags = replaceTags
