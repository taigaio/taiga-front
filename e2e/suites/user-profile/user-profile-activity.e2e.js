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

describe('user profile - activity', function() {
    describe('current user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + 'profile');

            await utils.common.waitLoader();

            utils.common.takeScreenshot('user-profile', 'current-user-activity');
        });

        it('activity tab - pagination', async function() {
            let startTotal = await $$('div[tg-user-timeline-item]').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
            await htmlChanges();

            let endTotal = await $$('div[tg-user-timeline-item]').count();

            let hasMoreItems = startTotal < endTotal;

            expect(hasMoreItems).to.be.equal(true);
        });

        it('conctacts tab', async function() {
            $$('.tab').get(4).click();

            browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'current-user-contacts');

            let contactsCount = await $$('.list-itemtype-user').count();

            expect(contactsCount).to.be.above(0);
        });

        utils.common.browserSkip('internet explorer', 'edit profile hover', async function() {
            let userImage = $('.profile-image-wrapper');

            await browser.actions().mouseMove(userImage).perform();

            let profileEdition = userImage.$('.profile-edition');

            await utils.common.waitTransitionTime(profileEdition);

            utils.common.takeScreenshot('user-profile', 'image-hover');

            let isDisplayed = await profileEdition.isDisplayed();

            expect(isDisplayed).to.be.true;
        });
    });

    describe('other user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + 'profile/user7');

            await utils.common.waitLoader();

            utils.common.takeScreenshot('user-profile', 'other-user-activity');
        });

        it('activity tab pagination', async function() {
            let startTotal = await $$('div[tg-user-timeline-item]').count();

            let htmlChanges = await utils.common.outerHtmlChanges('div[infinite-scroll]');
            await browser.executeScript('window.scrollTo(0,document.body.scrollHeight)');
            await htmlChanges();

            let endTotal = await $$('div[tg-user-timeline-item]').count();

            let hasMoreItems = startTotal < endTotal;

            expect(hasMoreItems).to.be.equal(true);
        });
    });
});
