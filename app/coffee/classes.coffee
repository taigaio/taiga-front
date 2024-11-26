###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
