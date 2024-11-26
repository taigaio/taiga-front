###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

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

                if config.map && data
                    data = data.map(config.map)

                items = items.concat(data)

                if items.size < config.minItems && response.get("next")
                    return getContent()

                pagination = Immutable.Map({
                    items: items,
                    total: response.get("total"),
                    next: response.get("next")
                })

                return pagination

        return {
            next: () -> next()
        }

    return obj

angular.module("taigaUserTimeline").factory("tgUserTimelinePaginationSequenceService", UserTimelinePaginationSequence)
