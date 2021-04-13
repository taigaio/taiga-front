class DiscoverHomeController
    @.$inject = [
        '$tgLocation',
        '$tgNavUrls',
        'tgAppMetaService',
        '$translate'
    ]

    constructor: (@location, @navUrls, @appMetaService, @translate) ->
        title = @translate.instant("DISCOVER.PAGE_TITLE")
        description = @translate.instant("DISCOVER.PAGE_DESCRIPTION")
        @appMetaService.setAll(title, description)

    onSubmit: (q) ->
        url = @navUrls.resolve('discover-search')

        @location.search('text', q).path(url)

angular.module("taigaDiscover").controller("DiscoverHome", DiscoverHomeController)
