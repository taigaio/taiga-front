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
# File: modules/common/custom-field-values.coffee
###

taiga = @.taiga
bindMethods = @.taiga.bindMethods
bindOnce = @.taiga.bindOnce
debounce = @.taiga.debounce
generateHash = taiga.generateHash

module = angular.module("taigaCommon")

# Custom attributes types (see taiga-back/taiga/projects/custom_attributes/choices.py)
TEXT_TYPE = "text"
RICHTEXT_TYPE = "url"
MULTILINE_TYPE = "multiline"
DATE_TYPE = "date"
URL_TYPE = "url"


TYPE_CHOICES = [
    {
        key: TEXT_TYPE,
        name: "ADMIN.CUSTOM_FIELDS.FIELD_TYPE_TEXT"
    },
    {
        key: MULTILINE_TYPE,
        name: "ADMIN.CUSTOM_FIELDS.FIELD_TYPE_MULTI"
    },
    {
        key: DATE_TYPE,
        name: "ADMIN.CUSTOM_FIELDS.FIELD_TYPE_DATE"
    },
    {
        key: URL_TYPE,
        name: "ADMIN.CUSTOM_FIELDS.FIELD_TYPE_URL"
    },
    {
        key: RICHTEXT_TYPE,
        name: "ADMIN.CUSTOM_FIELDS.FIELD_TYPE_RICHTEXT"
    }
]



class CustomAttributesValuesController extends taiga.Controller
    @.$inject = ["$scope", "$rootScope", "$tgRepo", "$tgResources", "$tgConfirm", "$q"]

    constructor: (@scope, @rootscope, @repo, @rs, @confirm, @q) ->
        bindMethods(@)
        @.type = null
        @.objectId = null
        @.projectId = null
        @.customAttributes = []
        @.customAttributesValues = null

    initialize: (type, objectId) ->
        @.project = @scope.project
        @.type = type
        @.objectId = objectId
        @.projectId = @scope.projectId

    loadCustomAttributesValues: ->
        return @.customAttributesValues if not @.objectId
        return @rs.customAttributesValues[@.type].get(@.objectId).then (customAttributesValues) =>
            @.customAttributes = @.project["#{@.type}_custom_attributes"]
            @.customAttributesValues = customAttributesValues
            return customAttributesValues

    getAttributeValue: (attribute) ->
        attributeValue = _.clone(attribute, false)
        attributeValue.value = @.customAttributesValues.attributes_values[attribute.id]
        return attributeValue

    updateAttributeValue: (attributeValue) ->
        onSuccess = =>
            @rootscope.$broadcast("custom-attributes-values:edit")

        onError = (response) =>
            @confirm.notify("error")
            return @q.reject()

        # We need to update the full array so angular understand the model is modified
        attributesValues = _.clone(@.customAttributesValues.attributes_values, true)
        attributesValues[attributeValue.id] = attributeValue.value
        @.customAttributesValues.attributes_values = attributesValues
        @.customAttributesValues.id = @.objectId
        return @repo.save(@.customAttributesValues).then(onSuccess, onError)


CustomAttributesValuesDirective = ($templates, $storage) ->
    template = $templates.get("custom-attributes/custom-attributes-values.html", true)

    collapsedHash = (type) ->
        return generateHash(["custom-attributes-collapsed", type])

    link = ($scope, $el, $attrs, $ctrls) ->
        $ctrl = $ctrls[0]
        $model = $ctrls[1]
        hash = collapsedHash($attrs.type)
        $scope.collapsed = $storage.get(hash) or false

        bindOnce $scope, $attrs.ngModel, (value) ->
            $ctrl.initialize($attrs.type, value.id)
            $ctrl.loadCustomAttributesValues()

        $scope.toggleCollapse = () ->
            $scope.collapsed = !$scope.collapsed
            $storage.set(hash, $scope.collapsed)

        $scope.$on "$destroy", ->
            $el.off()

    templateFn = ($el, $attrs) ->
        return template({
            requiredEditionPerm: $attrs.requiredEditionPerm
        })

    return {
        require: ["tgCustomAttributesValues", "ngModel"]
        controller: CustomAttributesValuesController
        controllerAs: "ctrl"
        restrict: "AE"
        scope: true
        link: link
        template: templateFn
    }

module.directive("tgCustomAttributesValues", ["$tgTemplate", "$tgStorage", "$translate",
                                              CustomAttributesValuesDirective])


CustomAttributeValueDirective = ($template, $selectedText, $compile, $translate, datePickerConfigService, wysiwygService) ->
    template = $template.get("custom-attributes/custom-attribute-value.html", true)
    templateEdit = $template.get("custom-attributes/custom-attribute-value-edit.html", true)

    link = ($scope, $el, $attrs, $ctrl) ->
        prettyDate = $translate.instant("COMMON.PICKERDATE.FORMAT")

        render = (attributeValue, edit=false) ->
            if attributeValue.type is DATE_TYPE and attributeValue.value
                value = moment(attributeValue.value, "YYYY-MM-DD").format(prettyDate)
            else
                value = attributeValue.value
            editable = isEditable()

            ctx = {
                id: attributeValue.id
                name: attributeValue.name
                description: attributeValue.description
                value: value
                isEditable: editable
                type: attributeValue.type
            }

            scope = $scope.$new()
            scope.attributeHtml = wysiwygService.getHTML(value)

            if editable and (edit or not value)
                html = templateEdit(ctx)

                html = $compile(html)(scope)
                $el.html(html)

                if attributeValue.type == DATE_TYPE
                    datePickerConfig = datePickerConfigService.get()
                    _.merge(datePickerConfig, {
                        field: $el.find("input[name=value]")[0]
                        onSelect: (date) =>
                            selectedDate = date
                        onOpen: =>
                            $el.picker.setDate(selectedDate) if selectedDate?
                    })
                    $el.picker = new Pikaday(datePickerConfig)
            else
                html = template(ctx)
                html = $compile(html)(scope)
                $el.html(html)

        isEditable = ->
            permissions = $scope.project.my_permissions
            requiredEditionPerm = $attrs.requiredEditionPerm
            return permissions.indexOf(requiredEditionPerm) > -1

        $scope.saveCustomRichText = (markdown, callback) =>
            attributeValue.value = markdown
            $ctrl.updateAttributeValue(attributeValue).then ->
                callback()
                render(attributeValue, false)

        $scope.cancelCustomRichText= () =>
            render(attributeValue, false)

            return null

        submit = debounce 2000, (event) =>
            event.preventDefault()

            form = $el.find("form").checksley()
            return if not form.validate()

            input = $el.find("input[name=value], textarea[name='value']")
            attributeValue.value = input.val()
            if attributeValue.type is DATE_TYPE
                if moment(attributeValue.value, prettyDate).isValid()
                    attributeValue.value = moment(attributeValue.value, prettyDate).format("YYYY-MM-DD")

            $scope.$apply ->
                $ctrl.updateAttributeValue(attributeValue).then ->
                    render(attributeValue, false)

        setFocusAndSelectOnInputField = ->
            $el.find("input[name='value'], textarea[name='value']").focus().select()

        # Bootstrap
        attributeValue = $scope.$eval($attrs.tgCustomAttributeValue)
        if attributeValue.value == null or attributeValue.value == undefined
            attributeValue.value = ""
        $scope.customAttributeValue = attributeValue
        render(attributeValue)

        ## Actions (on view mode)

        $el.on "click", ".js-value-view-mode span a", (event) ->
            event.stopPropagation()

        $el.on "click", ".js-value-view-mode", ->
            return if not isEditable()
            return if $selectedText.get().length
            render(attributeValue, true)
            setFocusAndSelectOnInputField()

        $el.on "click", ".js-edit-description", (event) ->
            event.preventDefault()
            render(attributeValue, true)
            setFocusAndSelectOnInputField()

        ## Actions (on edit mode)
        $el.on "keyup", "input[name=value], textarea[name='value']", (event) ->
            if event.keyCode is 13 and event.currentTarget.type isnt "textarea"
                submit(event)
            else if event.keyCode == 27
                render(attributeValue, false)

        $el.on "submit", "form", submit

        $el.on "click", ".js-save-description", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        require: "^tgCustomAttributesValues"
        restrict: "AE"
    }

module.directive("tgCustomAttributeValue", ["$tgTemplate", "$selectedText", "$compile", "$translate",
                                            "tgDatePickerConfigService", "tgWysiwygService", CustomAttributeValueDirective])
