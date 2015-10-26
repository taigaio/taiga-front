UserTimelinePaginationSequence = () ->
    obj = {}

    obj.generate = (config) ->
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
                    data = config.filter(data)

                if config.map
                    data = data.map(config.map)

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

    return obj

angular.module("taigaUserTimeline").factory("tgUserTimelinePaginationSequenceService", UserTimelinePaginationSequence)
