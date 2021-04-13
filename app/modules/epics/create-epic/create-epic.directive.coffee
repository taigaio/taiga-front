CreateEpicDirective = () ->
    link = (scope, el, attrs, ctrl) ->
        form = el.find("form").checksley()

        ctrl.validateForm = =>
            return form.validate()

        ctrl.setFormErrors = (errors) =>
            form.setErrors(errors)

    return {
        link: link,
        templateUrl:"epics/create-epic/create-epic.html",
        controller: "CreateEpicCtrl",
        controllerAs: "vm",
        bindToController: {
            onCreateEpic: '&'
        },
        scope: {}
    }

angular.module('taigaEpics').directive("tgCreateEpic", CreateEpicDirective)
