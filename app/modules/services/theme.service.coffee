taiga = @.taiga


class ThemeService extends taiga.Service = ->
    use: (themeName) ->
        stylesheetEl = $("link[rel='stylesheet']")

        if stylesheetEl.length == 0
            stylesheetEl = $("<link rel='stylesheet' href='' type='text/css'>")
            $("head").append(stylesheetEl)

        stylesheetEl.attr("href", "/styles/theme-#{themeName}.css")


angular.module("taigaCommon").service("tgThemeService", ThemeService)
