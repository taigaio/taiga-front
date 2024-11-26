###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

addClass = (el, className) ->
    if (el.classList)
        el.classList.add(className)
    else
        el.className += ' ' + className


nl2br = (str) =>
    breakTag = '<br />'
    return (str + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + breakTag + '$2')


bindMethods = (object) =>
    dependencies = _.keys(object)

    methods = []

    _.forIn object, (value, key) =>
        if key not in dependencies && _.isFunction(value)
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
    return _.trim(data, char)


slugify = (data) ->
    return data.toString().toLowerCase().trim()
        .replace(/\s+/g, '-')
        .replace(/&/g, '-and-')
        .replace(/[^\w\-]+/g, '')
        .replace(/\-\-+/g, '-')


unslugify = (data) ->
    if data
        return _.capitalize(data.replace(/-/g, ' '))
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
    return coll.join(str)


debounce = (wait, func) ->
    return _.debounce(func, wait, {leading: true, trailing: false})


debounceLeading = (wait, func) ->
    return _.debounce(func, wait, {leading: false, trailing: true})


startswith = (str1, str2) ->
    return _.startsWith(str1, str2)


truncate = (str, maxLength, suffix="...") ->
    return str if (typeof str != "string") and not (str instanceof String)

    out = str.slice(0)

    if out.length > maxLength
        out = out.substring(0, maxLength + 1)
        out = out.substring(0, Math.min(out.length, out.lastIndexOf(" ")))
        out = out + suffix

    return out


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


defineImmutableProperty = (obj, name, fn) =>
    Object.defineProperty obj, name, {
        get: () =>
            if !_.isFunction(fn)
                throw "defineImmutableProperty third param must be a function"

            fn_result = fn()
            if fn_result && _.isObject(fn_result)
                if fn_result.size == undefined
                    throw "defineImmutableProperty must return immutable data"

            return fn_result
    }


_.mixin
    removeKeys: (obj, keys) ->
        _.chain([keys]).flatten().reduce(
            (obj, key) ->
                delete obj[key]; obj
            , obj).value()

    cartesianProduct: ->
        _.reduceRight(
            arguments, (a,b) ->
                _.flatten(_.map(a, (x) -> _.map b, (y) -> [y].concat(x)), true)
            , [ [] ])


isImage = (name) ->
    return name.match(/\.(jpe?g|png|gif|gifv|svg|psd|webp)/i) != null

isEmail = (name) ->
    return name? and name.match(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/) != null

isPdf = (name) ->
    return name.match(/\.(pdf)/i) != null


patch = (oldImmutable, newImmutable) ->
    pathObj = {}

    newImmutable.forEach (newValue, key) ->
        if newValue != oldImmutable.get(key)
            if newValue.toJS
                pathObj[key] = newValue.toJS()
            else
                pathObj[key] = newValue

    return pathObj

DEFAULT_COLOR_LIST = [
    '#D35163', '#D351CF', '#AC51D3', '#8151D3', '#5551D3', '#5178D3', '#78D351',
    '#51D355', '#51D381', '#51D3AC', '#51CFD3', '#51A3D3', '#A3D350', '#CFD350',
    '#D3AC50', '#D38050', '#D35450', '#E44057', '#4C566A', '#70728F', '#A9AABC'
]

getRandomDefaultColor = () ->
    return _.sample(DEFAULT_COLOR_LIST)

getDefaulColorList = () ->
    return _.clone(DEFAULT_COLOR_LIST)

getMatches = (string, regex, index) ->
    index || (index = 1)
    matches = []
    match = null

    while match = regex.exec(string)
        if index == -1
            matches.push(match)
        else
            matches.push(match[index])

    return matches

randomInt = (start, end) ->
    interval = end - start
    return start + Math.floor(Math.random()*(interval+1))

normalizeString = (string) ->
    normalizedString = string
    normalizedString = normalizedString.replace("Á", "A").replace("Ä", "A").replace("À", "A")
    normalizedString = normalizedString.replace("É", "E").replace("Ë", "E").replace("È", "E")
    normalizedString = normalizedString.replace("Í", "I").replace("Ï", "I").replace("Ì", "I")
    normalizedString = normalizedString.replace("Ó", "O").replace("Ö", "O").replace("Ò", "O")
    normalizedString = normalizedString.replace("Ú", "U").replace("Ü", "U").replace("Ù", "U")
    return normalizedString

findScope = ($scope, condition) ->
    result = condition($scope)
    if result
        return result

    if $scope
        return findScope($scope.$parent, condition)

    return null

taiga = @.taiga
taiga.addClass = addClass
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
taiga.truncate = truncate
taiga.debounce = debounce
taiga.debounceLeading = debounceLeading
taiga.startswith = startswith
taiga.sizeFormat = sizeFormat
taiga.stripTags = stripTags
taiga.replaceTags = replaceTags
taiga.defineImmutableProperty = defineImmutableProperty
taiga.isImage = isImage
taiga.isEmail = isEmail
taiga.isPdf = isPdf
taiga.patch = patch
taiga.getRandomDefaultColor = getRandomDefaultColor
taiga.getDefaulColorList = getDefaulColorList
taiga.getMatches = getMatches
taiga.randomInt = randomInt
taiga.normalizeString = normalizeString
taiga.findScope = findScope
