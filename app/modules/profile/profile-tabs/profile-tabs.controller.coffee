class ProfileTabsController
    constructor: () ->
        @tabs = []

    addTab: (tab) ->
        @tabs.push(tab)

    toggleTab: (tab) ->
        _.map @tabs, (tab) -> tab.active = false

        tab.active = true

angular.module("taigaProfile")
    .controller("ProfileTabs", ProfileTabsController)
