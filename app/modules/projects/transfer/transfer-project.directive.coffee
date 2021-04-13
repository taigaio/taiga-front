module = angular.module('taigaProjects')

TransferProjectDirective = () ->
    link = (scope, el, attrs, ctrl) ->
      ctrl.initialize()

    return {
        link: link,
        scope: {},
        bindToController: {
            project: "="
        },
        templateUrl: "projects/transfer/transfer-project.html",
        controller: 'TransferProjectController',
        controllerAs: 'vm'
    }

module.directive('tgTransferProject', TransferProjectDirective)
