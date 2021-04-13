CustomFieldEditWysiwyg = (attachmentsFullService) ->
    link = ($scope, $el, $attrs) ->
        types = {
            epics: "epic",
            userstories: "us",
            userstory: "us",
            issues: "issue",
            tasks: "task",
            epic: "epic",
            us: "us"
            issue: "issue",
            task: "task",
        }

        $scope.uploadFiles = (file, cb) ->
            return attachmentsFullService.addAttachment($scope.project.id, $scope.ctrl.objectId.toString(), types[$scope.ctrl.type], file).then (result) ->
                cb({
                    default: result.getIn(['file', 'url'])
                })

    return {
        scope: true,
        link: link,
        template: """
            <div>
                <tg-wysiwyg
                    editonly="!!customAttributeValue.value.length"
                    project="project"
                    content='customAttributeValue.value'
                    on-save="saveCustomRichText(text, cb)"
                    on-cancel="cancelCustomRichText()"
                    on-upload-file='uploadFiles'>
                </tg-wysiwyg>
            </div>
        """
    }

angular.module("taigaComponents")
    .directive("tgCustomFieldEditWysiwyg", ["tgAttachmentsFullService", CustomFieldEditWysiwyg])
