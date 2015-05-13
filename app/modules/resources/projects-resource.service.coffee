Resource = (urlsService, http) ->
    service = {}

    service.getProjectBySlug = (projectSlug) ->
        url = urlsService.resolve("projects")

        url = "#{url}/by_slug?slug=#{projectSlug}"

        return http.get(url)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getProjectsByUserId = (userId) ->
        url = urlsService.resolve("projects")

        params = {"member": userId, "order_by": "memberships__user_order"}

        return http.get(url, params)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getProjectStats = (projectId) ->
        url = urlsService.resolve("projects")
        url = "#{url}/#{projectId}"

        return http.get(url)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.bulkUpdateOrder = (bulkData) ->
        url = urlsService.resolve("bulk-update-projects-order")
        return http.post(url, bulkData)

    service.getTimeline = (projectId, page) ->
        params = {
            page: page
        }

        url = urlsService.resolve("timeline-project")
        url = "#{url}/#{projectId}"

        return http.get(url, params).then (result) ->
            return Immutable.fromJS(result.data)

    return () ->
        return {"projects": service}

Resource.$inject = ["$tgUrls", "$tgHttp"]

module = angular.module("taigaResources2")
module.factory("tgProjectsResources", Resource)
