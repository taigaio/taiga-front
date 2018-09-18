###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: services/paginate-response.service.coffee
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
