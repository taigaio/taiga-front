###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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
