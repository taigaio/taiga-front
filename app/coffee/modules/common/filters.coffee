###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga

module = angular.module("taigaCommon")


defaultFilter = ->
    return (value, defaultValue) ->
        if value is [null, undefined]
            return defaultValue
        return value

module.filter("default", defaultFilter)


yesNoFilter = ($translate) ->
    return (value) ->
        if value
            return $translate.instant("COMMON.YES")

        return $translate.instant("COMMON.NO")

module.filter("yesNo", ["$translate", yesNoFilter])


unslugify = ->
    return taiga.unslugify

module.filter("unslugify", unslugify)


momentFormat = ->
    return (input, format) ->
        if input
            return moment(input).format(format)
        return ""

module.filter("momentFormat", momentFormat)


momentFromNow = ->
    return (input, without_suffix) ->
        if input
            return moment(input).fromNow(without_suffix or false)
        return ""

module.filter("momentFromNow", momentFromNow)


sizeFormat = =>
    return @.taiga.sizeFormat

module.filter("sizeFormat", sizeFormat)

toMutableFilter =  ->
    toMutable = (js) ->
      return js.toJS()

    memoizedMutable = _.memoize(toMutable)

    return (input) ->
      if input instanceof Immutable.List
        return memoizedMutable(input)

      return input

module.filter("toMutable", toMutableFilter)


byRefFilter = ($filterFilter)->
    return (userstories, filter) ->
        if filter?.startsWith("#")
            cleanRef= filter.substr(1)
            return _.filter(userstories, (us) => String(us.ref).startsWith(cleanRef))

        return $filterFilter(userstories, filter)

module.filter("byRef", ["filterFilter", byRefFilter])


darkerFilter = ->
    return (color, luminosity) ->
        if !color
            return 'transparent'

        # validate hex string
        color = new String(color).replace(/[^0-9a-f]/gi, '')
        if color.length < 6
            color = color[0]+ color[0]+ color[1]+ color[1]+ color[2]+ color[2];

        luminosity = luminosity || 0

        # convert to decimal and change luminosity
        newColor = "#"
        c = 0
        i = 0
        black = 0
        white = 255
        # for (i = 0; i < 3; i++)
        for i in [0, 1, 2]
            c = parseInt(color.substr(i*2,2), 16)
            c = Math.round(Math.min(Math.max(black, c + (luminosity * white)), white)).toString(16)
            newColor += ("00"+c).substr(c.length)

        return newColor


module.filter("darker", darkerFilter)

markdownToHTML = (wysiwigService) ->
    return (input) ->
        if input
            return wysiwigService.getHTML(input)

        return ""

module.filter("markdownToHTML", ["tgWysiwygService", markdownToHTML])

inArray = ($filter) ->
    return (list, arrayFilter, element) ->
        if arrayFilter
            filter = $filter("filter")
            return filter list, (listItem) ->
                return arrayFilter.indexOf(listItem[element]) != -1
module.filter("inArray", ["$filter", inArray])

emojify = ($emojis) ->
    return (input) ->
        if input
            return _.unescape($emojis.replaceEmojiNameByHtmlImgs(_.escape(input)))

        return ""

module.filter("emojify", ["$tgEmojis", emojify])

textToHTML = ($filter) ->
    return (input) ->
        if input
            return input.replace(/\<(?!(\/?)(strong|br)(\/?)).*?\>/g, "")

        return ""

module.filter("textToHTML", ["$filter", textToHTML])
