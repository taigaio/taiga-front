taiga = @.taiga

resourceProvider = ($repo) ->
    service = {}

    service.get = (token) ->
        return $repo.queryOne("invitations", token)

    return (instance) ->
        instance.invitations = service


module = angular.module("taigaResources")
module.factory("$tgInvitationsResourcesProvider", ["$tgRepo", resourceProvider])
