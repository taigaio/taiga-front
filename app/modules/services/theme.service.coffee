taiga = @.taiga


class ThemeService extends taiga.Service
    use: (themeName) ->
        stylesheetEl = $("link[rel='stylesheet']:first")

        if stylesheetEl.length == 0
            stylesheetEl = $("<link rel='stylesheet' href='' type='text/css'>")
            $("head").append(stylesheetEl)

        stylesheetEl.attr("href", "/#{window._version}/styles/theme-#{themeName}.css")


angular.module("taigaCommon").service("tgThemeService", ThemeService)
