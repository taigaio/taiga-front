class SelectImportUserLightboxCtrl
    @.$inject = []

    constructor: () ->

    start: () ->
        @.mode = 'search'
        @.invalid = false

    assignUser: () ->
        @.onSelectUser({user: @.user, taigaUser: @.userEmail})

    selectUser: (taigaUser) ->
        @.onSelectUser({user: @.user, taigaUser: Immutable.fromJS(taigaUser)})

angular.module('taigaProjects').controller('SelectImportUserLightboxCtrl', SelectImportUserLightboxCtrl)
