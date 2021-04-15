###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

ClickInputFile = () ->
  return {
      link:  (scope, el) ->
          el.on 'click', (e) ->
              if !$(e.target).is('input')
                  e.preventDefault()
                  inputFile = el.find('input[type="file"]')
                  inputFile.val('')
                  inputFile.trigger('click')

          scope.$on "$destroy", -> el.off()
  }

angular.module("taigaComponents")
    .directive("tgClickInputFile", [ClickInputFile])
