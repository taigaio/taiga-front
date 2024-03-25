/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');
var helper = module.exports;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

helper.assignToLightbox = function() {
    let el = $('div[tg-lb-assignedto]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        close: function() {
            el.$$('.close').first().click();
        },
        selectFirst: function() {
            el.$$('div[data-user-id]').first().click();
        },
        select: function(index) {
            el.$$('div[data-user-id]').get(index).click();
        },
        getName: function(item) {
            return el.$$('div[data-user-id] .user-list-name').get(item).getText();
        },
        getNames: function() {
            return el.$$('.user-list-name').getText();
        },
        filter: function(text) {
            return el.$('input').sendKeys(text);
        },
        userList: function() {
            return el.$$('.user-list-single');
        }
    };

    return obj;
};

helper.lightboxAttachment = async function() {
    let el = $('tg-attachments-simple');

    let addAttachment = el.$('#add-attach');

    let countAttachments = await el.$$('.single-attachment').count();

    var fileToUpload1 = utils.common.uploadImagePath();
    var fileToUpload2 = utils.common.uploadFilePath();

    await utils.common.uploadFile(addAttachment, fileToUpload1);
    await utils.common.uploadFile(addAttachment, fileToUpload2);

    el.$$('.attachment-delete').get(0).click();

    let newCountAttachments = await el.$$('.single-attachment').count();

    expect(countAttachments + 1).to.be.equal(newCountAttachments);
};

helper.tags = function() {
    $('.e2e-show-tag-input').click();
    $('.e2e-open-color-selector').click();

    $$('.e2e-color-dropdown li').get(1).click();
    $('.e2e-add-tag-input')
        .sendKeys('xxxyy')
        .sendKeys(protractor.Key.ENTER);

    $$('.e2e-delete-tag').last().click();

    $('.e2e-add-tag-input')
        .sendKeys('a')
        .sendKeys(protractor.Key.ARROW_DOWN)
        .sendKeys(protractor.Key.ENTER);
}
