###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class TaigaBase
class TaigaService extends TaigaBase
class TaigaController extends TaigaBase
    onInitialDataError: (xhr) =>
        if xhr
            if xhr.status == 404
                @errorHandlingService.notfound()
            else if xhr.status == 403
                @errorHandlingService.permissionDenied()

        return @q.reject(xhr)

@.taiga.Base = TaigaBase
@.taiga.Service = TaigaService
@.taiga.Controller = TaigaController
