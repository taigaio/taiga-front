###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

PaginateResponse = () ->
    return (result) ->
        paginateResponse = Immutable.Map({
            "data": result.get("data"),
            "next": !!result.get("headers")("x-pagination-next"),
            "prev": !!result.get("headers")("x-pagination-prev"),
            "current": result.get("headers")("x-pagination-current"),
            "count": result.get("headers")("x-pagination-count")
        })

        return paginateResponse

angular.module("taigaCommon").factory("tgPaginateResponseService", PaginateResponse)
