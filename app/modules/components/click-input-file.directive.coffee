###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
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
