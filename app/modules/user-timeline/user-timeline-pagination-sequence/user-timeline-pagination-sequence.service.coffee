UserTimelinePaginationSequence = () ->
    return (config) ->
        page = 1
        items = Immutable.List()

        config.minItems = config.minItems || 20

        next = () ->
            items = Immutable.List()
            return getContent()

        getContent = () ->
            config.fetch(page).then (response) ->
                page++

                data = response.get("data")

                if config.filter
                    data = config.filter(response.get("data"))

                items = items.concat(data)

                if items.size < config.minItems && response.get("next")
                    return getContent()

                return Immutable.Map({
                    items: items,
                    next: response.get("next")
                })

        return {
            next: () -> next()
        }

angular.module("taigaUserTimeline").factory("tgUserTimelinePaginationSequenceService", UserTimelinePaginationSequence)
