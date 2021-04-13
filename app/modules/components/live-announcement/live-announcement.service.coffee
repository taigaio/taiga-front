class LiveAnnouncementService extends taiga.Service
    constructor: () ->
        @.open = false
        @.title = ""
        @.desc = ""

    show: (title, desc) ->
        @.open = true
        @.title = title
        @.desc = desc

angular.module("taigaComponents").service("tgLiveAnnouncementService", LiveAnnouncementService)
