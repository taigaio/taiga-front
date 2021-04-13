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
