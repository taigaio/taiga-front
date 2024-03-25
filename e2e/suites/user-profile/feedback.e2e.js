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

describe('feedback', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'user-settings/mail-notifications');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('edit-user-profile', 'mail-notifications');
    });

    it('send feedback', async function() {
        let menu = utils.common.getMenu();
        let menuOption = $('a[translate="PROJECT.NAVIGATION.FEEDBACK"]');

        browser.actions().mouseMove(menu).perform();
        browser.actions().mouseMove(menuOption).click().perform();

        let feedbackLightbox = $('div[tg-lb-feedback]');

        await utils.lightbox.open(feedbackLightbox);

        await feedbackLightbox.$('textarea').sendKeys('test test test');

        feedbackLightbox.$('button[type=submit]').click();

        let notificationOpen = await utils.notifications.success.open();

        expect(notificationOpen).to.be.true;
    });
});
