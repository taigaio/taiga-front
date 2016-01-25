var utils = require('../utils');

var helper = module.exports;

helper.create = function(indexType, name, desc, option) {
    let type = $$('div[tg-project-custom-attributes]').get(indexType);

    type.$('.js-add-custom-field-button').click();

    let form = type.$$('form').last();

    form.$('input[name="name"]').sendKeys(name);
    form.$('input[name="description"]').sendKeys(desc);
    form.$(`select option:nth-child(${option})`).click();

    let saveButton = form.$('.js-create-custom-field-button');

    browser.actions()
        .mouseMove(saveButton)
        .click()
        .perform();
};

helper.edit = function(indexType, indexCustomField, name, desc, option) {
    let form = helper.getCustomFiledsByType(indexType).get(indexCustomField);

    browser.actions()
        .mouseMove(form.$('.js-edit-custom-field-button'))
        .click()
        .perform();

    form.$('input[name="name"]').sendKeys(name);
    form.$('input[name="description"]').sendKeys(desc);
    form.$(`select option:nth-child(${option})`).click();

    let saveButton = form.$('.js-update-custom-field-button');

    browser.actions()
        .mouseMove(saveButton)
        .click()
        .perform();
};

helper.drag = function(indexType, indexCustomField, indexNewPosition) {
    let customField = helper.getCustomFiledsByType(indexType).get(indexCustomField);
    let newPosition = helper.getCustomFiledsByType(indexType).get(indexNewPosition).getLocation();

    return utils.common.drag(customField, newPosition, {y: 30});
};

helper.getCustomFiledsByType = function(indexType) {
    return $$('div[tg-project-custom-attributes]').get(indexType).$$('.js-sortable > div');
};

helper.delete = async function(indexType, indexCustomField) {
    let customField = helper.getCustomFiledsByType(indexType).get(indexCustomField);

    browser.actions()
        .mouseMove(customField.$('.js-delete-custom-field-button'))
        .click()
        .perform();

    return utils.lightbox.confirm.ok();
};

helper.getName = function(indexType, indexCustomField) {
    return helper.getCustomFiledsByType(indexType).get(indexCustomField).$('.custom-name span').getText();
};

helper.getDetailFields = function() {
    return $$('.custom-fields-body div[tg-custom-attribute-value]');
};
