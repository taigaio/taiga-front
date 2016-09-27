var utils = require('../utils');
var commonHelper = require('./common-helper');

var helper = module.exports;


helper.colorEditor = function() {
    let el = $('tg-color-selector');

    let obj = {
        el: el,

        open: async function(){
            await el.$(".e2e-open-color-selector").click();
        },

        selectFirstColor: async function() {
            let color = el.$$(".color-selector-option").first();
            color.click();
            await browser.waitForAngular();
        },

        selectLastColor: async function() {
            let color = el.$$(".color-selector-option").last();
            color.click();
            await browser.waitForAngular();
        }
    };

    return obj;
};

helper.relatedUserstories = function() {
    let el = $('tg-related-userstories');

    let obj = {
        el: el,

        createNewUserStory: async function(subject) {
            el.$(".e2e-add-userstory-button").click();
            el.$(".e2e-new-userstory-label").click();
            el.$(".e2e-single-creation-label").click();
            el.$(".e2e-new-userstory-input-text").sendKeys(subject);
            el.$(".e2e-create-userstory-button").click();
            await browser.waitForAngular();
        },

        createNewUserStories: async function(subject) {
            el.$(".e2e-add-userstory-button").click();
            el.$(".e2e-new-userstory-label").click();
            el.$(".e2e-bulk-creation-label").click();
            el.$(".e2e-new-userstories-input-textarea").sendKeys(subject);
            el.$(".e2e-create-userstory-button").click();
            await browser.waitForAngular();
        },

        selectFirstRelatedUserstory: async function() {
            el.$(".e2e-add-userstory-button").click();
            el.$(".e2e-existing-user-story-label").click();
            el.$(".e2e-filter-userstories-input").click().sendKeys("#1");
            await browser.waitForAngular();
            el.$$(".e2e-userstories-select option").get(1).click()
            el.$(".e2e-select-related-userstory-button").click();
            await browser.waitForAngular();
        },

        deleteFirstRelatedUserstory: async function() {
            let relatedUSRow = el.$$("tg-related-userstory-row").first();
            browser.actions().mouseMove(relatedUSRow).perform();
            relatedUSRow.$(".e2e-delete-userstory").click();
            await utils.lightbox.confirm.ok();
        }
    };

    return obj;
}
