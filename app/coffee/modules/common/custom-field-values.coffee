###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
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
MULTILINE_TYPE = "multiline"
DATE_TYPE = "date"


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

        bindOnce $scope, $attrs.ngModel, (value) ->
            $ctrl.initialize($attrs.type, value.id)
            $ctrl.loadCustomAttributesValues()

        $el.on "click", ".custom-fields-header a", ->
            hash = collapsedHash($attrs.type)
            collapsed = not($storage.get(hash) or false)
            $storage.set(hash, collapsed)
            if collapsed
                $el.find(".custom-fields-header a").removeClass("open")
                $el.find(".custom-fields-body").removeClass("open")
            else
                $el.find(".custom-fields-header a").addClass("open")
                $el.find(".custom-fields-body").addClass("open")

        $scope.$on "$destroy", ->
            $el.off()

    templateFn = ($el, $attrs) ->
        collapsed = $storage.get(collapsedHash($attrs.type)) or false

        return template({
            requiredEditionPerm: $attrs.requiredEditionPerm
            collapsed: collapsed
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


CustomAttributeValueDirective = ($template, $selectedText, $compile, $translate, datePickerConfigService) ->
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

            if editable and (edit or not value)
                html = templateEdit(ctx)
                html = $compile(html)($scope)
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
                html = $compile(html)($scope)
                $el.html(html)

        isEditable = ->
            permissions = $scope.project.my_permissions
            requiredEditionPerm = $attrs.requiredEditionPerm
            return permissions.indexOf(requiredEditionPerm) > -1

        submit = debounce 2000, (event) =>
            event.preventDefault()

            attributeValue.value = $el.find("input[name=value], textarea[name='value']").val()
            if attributeValue.type is DATE_TYPE
                if moment(attributeValue.value, prettyDate).isValid()
                    attributeValue.value = moment(attributeValue.value, prettyDate).format("YYYY-MM-DD")
                else
                    attributeValue.value = ""

            $scope.$apply ->
                $ctrl.updateAttributeValue(attributeValue).then ->
                    render(attributeValue, false)

        setFocusOnInputField = ->
            $el.find("input[name='value'], textarea[name='value']").focus()

        # Bootstrap
        attributeValue = $scope.$eval($attrs.tgCustomAttributeValue)
        render(attributeValue)

        ## Actions (on view mode)
        $el.on "click", ".js-value-view-mode", ->
            return if not isEditable()
            return if $selectedText.get().length
            render(attributeValue, true)
            setFocusOnInputField()

        $el.on "click", "a.icon-edit", (event) ->
            event.preventDefault()
            render(attributeValue, true)
            setFocusOnInputField()

        ## Actions (on edit mode)
        $el.on "keyup", "input[name=value], textarea[name='value']", (event) ->
            if event.keyCode is 13 and event.currentTarget.type isnt "textarea"
                submit(event)
            else if event.keyCode == 27
                render(attributeValue, false)

        $el.on "submit", "form", submit

        $el.on "click", "a.icon-floppy", submit

        $scope.$on "$destroy", ->
            $el.off()

    return {
        link: link
        require: "^tgCustomAttributesValues"
        restrict: "AE"
    }

module.directive("tgCustomAttributeValue", ["$tgTemplate", "$selectedText", "$compile", "$translate",
                                            "tgDatePickerConfigService", CustomAttributeValueDirective])
