/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.links = function() {
    let el = $('sidebar[tg-wiki-nav]');

    let obj = {
        el: el,

        addLink: async function(pageTitle){
            el.$(".add-button").click();
            el.$(".new input").sendKeys(pageTitle);
            browser.actions().sendKeys(protractor.Key.ENTER).perform();
            await browser.waitForAngular();
            let newLink = await el.$$(".e2e-wiki-page-link a").last();
            return newLink;
        },

        get: function(index) {
            if(index !== null && index !== undefined) {
                return el.$$(".e2e-wiki-page-link a.link-title").get(index);
            }

            return el.$$(".e2e-wiki-page-link a.link-title");
        },

        row: function(index) {
            return el.$$(".e2e-wiki-page-link").get(index);
        },

        getNameOf: async function(index) {
            let item = await obj.get(index);
            return item.getText();
        },

        deleteLink: async function(link){
            link.click();
            await utils.lightbox.confirm.ok();
            await browser.waitForAngular();
        }

    };

    return obj;
};

helper.dragAndDropLinks = async function(indexFrom, indexTo) {
    let selectedLink = helper.links().row(indexFrom).$('.dragger');

    let newPosition = helper.links().get(indexTo).getLocation();
    return utils.common.drag(selectedLink, newPosition);
};

helper.editor = function(){
    let el = $('.main.wiki');

    let obj = {
        el: el,

        focus: function() {
            el.$("textarea").click();
        },

        enabledEditionMode: async function(){
            await el.$("section[tg-editable-wiki-content] .view-wiki-content").click();
        },

        getTimesEdited: async function(){
            let total = await el.$(".wiki-times-edited .number").getText();
            return total;
        },

        getLastEditionDateTime: async function(){
            let date = await el.$(".wiki-last-modified .number").getText();
            return date;
        },

        getLastEditor: async function(){
            let editor = await el.$(".wiki-user-modification .username").getText();
            return editor;
        },

        getInnerHtml: async function(text){
            let wikiText = await el.$(".view-wiki-content .wysiwyg").getAttribute("innerHTML");
            return wikiText;
        },

        getText: async function(text){
            let wikiText = await el.$("textarea").getAttribute('value');
            return wikiText;
        },

        setText: async function(text){
            await el.$("textarea").clear().sendKeys(text);
        },

        preview: async function(){
            await el.$(".preview-icon a").click();
            await browser.waitForAngular();
        },
        closePreview: async function(){
            await el.$(".actions .wysiwyg").click();
            await browser.waitForAngular();
        },
        save: async function(){
            await el.$(".save").click();
            await browser.waitForAngular();
        },

        delete: async function(){
            await el.$('.remove').click();
            await utils.lightbox.confirm.ok();
            await browser.waitForAngular();
        }

    };

    return obj;
};
