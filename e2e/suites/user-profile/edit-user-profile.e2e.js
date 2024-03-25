/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('edit user profile', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'user-settings/user-profile');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('edit-user-profile', 'edit-user-profile');
    });

    it('edit fullname', async function() {
        $('#full-name').clear().sendKeys('admin-' + Date.now());

        $('button[type="submit"]').click();

        let successOpen = await utils.notifications.success.open();

        expect(successOpen).to.be.ok;

        // debounce :(
        await browser.sleep(2000);
    });

    it('update email', async function() {
        let email = $('#email');

        await email.clear().sendKeys('admin+1@admin.com');

        $('button[type="submit"]').click();

        let lb = $('.lightbox-generic-success');

        await utils.lightbox.open(lb);

        lb.$('.button-green').click();

        await utils.lightbox.close(lb);

        // debounce :(
        await browser.sleep(2000);
    });

    it('edit lenguage', async function() {
        // english
        $('#lang option:nth-child(4)').click();
        $('button[type="submit"]').click();

        await utils.notifications.success.open();

        //debounce
        browser.sleep(2000);

        let pageTitle = await $('h1 span').getText();
        let lang = $('#lang option:nth-child(2)').click();

        $('button[type="submit"]').click();

        await utils.notifications.success.open();

        let newPageTitle = await $('h1 span').getText();

        expect(newPageTitle).to.be.not.equal(pageTitle);

        //debounce
        browser.sleep(2000);

        // revert english
        $('#lang option:nth-child(4)').click();
        $('button[type="submit"]').click();

        await utils.notifications.success.open();

        //debounce
        browser.sleep(2000);
    });

    it('edit avatar', async function() {
        let inputFile = $('#avatar-field');

        let imageContainer = $('.image-container');

        let htmlChanges = await utils.common.outerHtmlChanges(imageContainer);
        var fileToUpload = utils.common.uploadImagePath();

        await utils.common.uploadFile(inputFile, fileToUpload);

        await htmlChanges();

        let avatar = imageContainer.$('.image');

        let src = await avatar.getAttribute('src');

        expect(src).to.contains('upload-image-test.png');
    });
});
