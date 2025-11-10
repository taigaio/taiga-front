###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

taiga = @.taiga
module = angular.module("taigaCommon")


class LocaleService extends taiga.Service
    @.$inject = [
        "$window",
        "$translate",
        "$tgStorage",
        "$tgConfig",
        "$rootScope"
    ]

    constructor: (@win, @translate, @storage, @config, @rootScope) ->
        @.currentLocale = null
        @.LOCALE_CACHE_KEY = "taiga.locale"

    initialize: ->
        cachedLocale = @.getCachedLocale()
        if cachedLocale
            @.currentLocale = cachedLocale
            @.applyLocale(cachedLocale, false)
        else
            defaultLocale = @config.get("defaultLanguage") || "en"
            @.setLocale(defaultLocale)

    getCachedLocale: ->
        return @storage.get(@.LOCALE_CACHE_KEY)

    getAvailableLocales: ->
        return [
            { code: "en", name: "English", nativeName: "English" }
            { code: "es", name: "Spanish", nativeName: "Español" }
            { code: "fr", name: "French", nativeName: "Français" }
            { code: "de", name: "German", nativeName: "Deutsch" }
            { code: "it", name: "Italian", nativeName: "Italiano" }
            { code: "pt-br", name: "Portuguese (Brazil)", nativeName: "Português (Brasil)" }
            { code: "ru", name: "Russian", nativeName: "Русский" }
            { code: "zh-hans", name: "Chinese (Simplified)", nativeName: "简体中文" }
            { code: "zh-hant", name: "Chinese (Traditional)", nativeName: "繁體中文" }
            { code: "ja", name: "Japanese", nativeName: "日本語" }
            { code: "ko", name: "Korean", nativeName: "한국어" }
            { code: "ar", name: "Arabic", nativeName: "العربية" }
            { code: "fa", name: "Persian", nativeName: "فارسی" }
            { code: "he", name: "Hebrew", nativeName: "עברית" }
            { code: "tr", name: "Turkish", nativeName: "Türkçe" }
            { code: "nl", name: "Dutch", nativeName: "Nederlands" }
            { code: "pl", name: "Polish", nativeName: "Polski" }
            { code: "fi", name: "Finnish", nativeName: "Suomi" }
            { code: "sv", name: "Swedish", nativeName: "Svenska" }
            { code: "da", name: "Danish", nativeName: "Dansk" }
            { code: "nb", name: "Norwegian", nativeName: "Norsk" }
            { code: "cs", name: "Czech", nativeName: "Čeština" }
            { code: "hu", name: "Hungarian", nativeName: "Magyar" }
            { code: "uk", name: "Ukrainian", nativeName: "Українська" }
            { code: "sr", name: "Serbian", nativeName: "Српски" }
            { code: "lv", name: "Latvian", nativeName: "Latviešu" }
            { code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia" }
            { code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt" }
            { code: "ca", name: "Catalan", nativeName: "Català" }
        ]

    setLocale: (localeCode, updateUser = true) ->
        if not localeCode or localeCode == @.currentLocale
            return Promise.resolve()

        @.currentLocale = localeCode
        @storage.set(@.LOCALE_CACHE_KEY, localeCode)
        
        return @.applyLocale(localeCode, updateUser)

    applyLocale: (localeCode, updateUser = true) ->
        @translate.preferredLanguage(localeCode)
        
        return @translate.use(localeCode).then =>
            @._configureMoment(localeCode)
            @._updateHtmlLang(localeCode)
            @._setRTL(localeCode)
            
            @rootScope.$broadcast("locale:changed", localeCode)
            
            return localeCode

    _configureMoment: (localeCode) ->
        if @win.moment
            momentLocale = @._getMomentLocale(localeCode)
            @win.moment.locale(momentLocale)
            
            if localeCode == "zh-hans"
                @win.moment.updateLocale('zh-cn', {
                    months: '一月_二月_三月_四月_五月_六月_七月_八月_九月_十月_十一月_十二月'.split('_')
                    monthsShort: '1月_2月_3月_4月_5月_6月_7月_8月_9月_10月_11月_12月'.split('_')
                    weekdays: '星期日_星期一_星期二_星期三_星期四_星期五_星期六'.split('_')
                    weekdaysShort: '周日_周一_周二_周三_周四_周五_周六'.split('_')
                    weekdaysMin: '日_一_二_三_四_五_六'.split('_')
                    longDateFormat: {
                        LT: 'HH:mm'
                        LTS: 'HH:mm:ss'
                        L: 'YYYY年MM月DD日'
                        LL: 'YYYY年MM月DD日'
                        LLL: 'YYYY年MM月DD日 HH:mm'
                        LLLL: 'YYYY年MM月DD日 dddd HH:mm'
                        l: 'YYYY-MM-DD'
                        ll: 'YYYY年MM月DD日'
                        lll: 'YYYY年MM月DD日 HH:mm'
                        llll: 'YYYY年MM月DD日 dddd HH:mm'
                    }
                    meridiemParse: /凌晨|早上|上午|中午|下午|晚上/
                    meridiemHour: (hour, meridiem) ->
                        if hour == 12
                            hour = 0
                        if meridiem == '凌晨' or meridiem == '早上' or meridiem == '上午'
                            return hour
                        else if meridiem == '下午' or meridiem == '晚上'
                            return hour + 12
                        else
                            return hour >= 11 ? hour : hour + 12
                    meridiem: (hour, minute, isLower) ->
                        hm = hour * 100 + minute
                        if hm < 600
                            return '凌晨'
                        else if hm < 900
                            return '早上'
                        else if hm < 1130
                            return '上午'
                        else if hm < 1230
                            return '中午'
                        else if hm < 1800
                            return '下午'
                        else
                            return '晚上'
                    calendar: {
                        sameDay: '[今天] LT'
                        nextDay: '[明天] LT'
                        nextWeek: '[下]dddd LT'
                        lastDay: '[昨天] LT'
                        lastWeek: '[上]dddd LT'
                        sameElse: 'L'
                    }
                    dayOfMonthOrdinalParse: /\d{1,2}(日|月|周)/
                    ordinal: (number, period) ->
                        switch period
                            when 'd', 'D', 'DDD'
                                return number + '日'
                            when 'M'
                                return number + '月'
                            when 'w', 'W'
                                return number + '周'
                            else
                                return number
                    relativeTime: {
                        future: '%s后'
                        past: '%s前'
                        s: '几秒'
                        ss: '%d 秒'
                        m: '1 分钟'
                        mm: '%d 分钟'
                        h: '1 小时'
                        hh: '%d 小时'
                        d: '1 天'
                        dd: '%d 天'
                        w: '1 周'
                        ww: '%d 周'
                        M: '1 个月'
                        MM: '%d 个月'
                        y: '1 年'
                        yy: '%d 年'
                    }
                    week: {
                        dow: 1
                        doy: 4
                    }
                })

    _getMomentLocale: (localeCode) ->
        momentLocaleMap = {
            "en": "en"
            "es": "es"
            "fr": "fr"
            "de": "de"
            "it": "it"
            "pt-br": "pt-br"
            "ru": "ru"
            "zh-hans": "zh-cn"
            "zh-hant": "zh-tw"
            "ja": "ja"
            "ko": "ko"
            "ar": "ar"
            "fa": "fa"
            "he": "he"
            "tr": "tr"
            "nl": "nl"
            "pl": "pl"
            "fi": "fi"
            "sv": "sv"
            "da": "da"
            "nb": "nb"
            "cs": "cs"
            "hu": "hu"
            "uk": "uk"
            "sr": "sr"
            "lv": "lv"
            "id": "id"
            "vi": "vi"
            "ca": "ca"
        }
        
        return momentLocaleMap[localeCode] || localeCode

    _updateHtmlLang: (localeCode) ->
        if @win.document
            @win.document.documentElement.setAttribute('lang', localeCode)

    _setRTL: (localeCode) ->
        rtlLanguages = @config.get("rtlLanguages", [])
        isRTL = rtlLanguages.indexOf(localeCode) > -1
        
        @rootScope.isRTL = isRTL
        
        if @win.document
            if isRTL
                @win.document.documentElement.setAttribute('dir', 'rtl')
            else
                @win.document.documentElement.removeAttribute('dir')

    getCurrentLocale: ->
        return @.currentLocale || @config.get("defaultLanguage") || "en"

    getLocaleInfo: (localeCode) ->
        locales = @.getAvailableLocales()
        return _.find(locales, { code: localeCode })

module.service("tgLocaleService", LocaleService)
