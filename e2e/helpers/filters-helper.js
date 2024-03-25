/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.getFilter = function() {
    return $('tg-filter');
};

helper.open = async function() {
    let isPresent = await $('.e2e-open-filter').isPresent();

    if(isPresent) {
        $('.e2e-open-filter').click();
    } else {
        return;
    }

    var filter = helper.getFilter();

    return utils.common.transitionend('tg-filter');
};

helper.byText = function(text) {
    return $('.e2e-filter-q').sendKeys(text);
};

helper.clearByTextInput = function() {
    return utils.common.clear($('.e2e-filter-q'));
};

helper.clearFilters = async function() {
    let filters = $$('.e2e-remove-filter');
    let filtersSize = await filters.count()

    for(var i = 0; i < filtersSize; i++) {
        filters.get(i).click();
    }

    await helper.clearByTextInput();
    let isPresent = await $('.e2e-category.selected').isPresent();

    if(isPresent) {
        $('.e2e-category.selected').click();
    }
};

helper.getFiltersCounters = function() {
    return $$('.e2e-filter-count');
};

helper.getCustomFilters = function() {
    return $$('.e2e-custom-filter');
};

helper.firterByLastCustomFilter = function() {
    helper.openCustomFiltersCategory();
    helper.getCustomFilters().last().click();
};

helper.openCustomFiltersCategory = function() {
    $('.e2e-custom-filters').click();
};

helper.removeLastCustomFilter = function() {
    $$('.e2e-remove-custom-filter').last().click();
}

helper.firterByCategoryWithContent = function() {
    $$('.e2e-category').first().click();

    let filter = helper.getFiltersCounters().first().element(by.xpath('..'));

    return filter.click();
};

helper.saveFilter = async function(name) {
    $('.e2e-open-custom-filter-form').click();

    await $('.e2e-filter-name-input').sendKeys(name);
    await $('.e2e-filter-name-input').sendKeys(protractor.Key.ENTER);
};
