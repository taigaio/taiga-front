class ImportProjectSelectorController
    selectProject: (project) ->
        @.onSelectProject({project: Immutable.fromJS(project)})

angular.module('taigaProjects').controller('ImportProjectSelectorCtrl', ImportProjectSelectorController)
