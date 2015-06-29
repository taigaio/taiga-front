pagination = () ->

Resource = (urlsService, http, paginateResponseService) ->
    service = {}

    service.getProjectBySlug = (projectSlug) ->
        url = urlsService.resolve("projects")

        url = "#{url}/by_slug?slug=#{projectSlug}"

        return http.get(url)
            .then (result) ->
                return Immutable.fromJS(result.data)

    service.getProjectsByUserId = (userId, paginate=false) ->
        url = urlsService.resolve("projects")
        httpOptions = {}

        if !paginate
            httpOptions.headers = {
                "x-disable-pagination": "1"
            }

        params = {"member": userId, "order_by": "memberships__user_order"}

        return http.get(url, params, httpOptions)
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
            result = Immutable.fromJS(result)
            return paginateResponseService(result)

    return () ->
        return {"projects": service}

Resource.$inject = ["$tgUrls", "$tgHttp", "tgPaginateResponseService"]

module = angular.module("taigaResources2")
module.factory("tgProjectsResources", Resource)
