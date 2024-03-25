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

describe('user profile - contacts', function() {
    describe('current user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile');

            await utils.common.waitLoader();

            $$('.tab').get(4).click();

            await browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'current-user-contacts');
        });

        it('conctacts tab', async function() {
            let contactsCount = await $$('.list-itemtype-user').count();

            expect(contactsCount).to.be.above(0);
        });
    });

    describe('other user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile/user7');

            await utils.common.waitLoader();

            $$('.tab').get(5).click();

            await browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-contacts');
        });

        it('conctacts tab', async function() {
            let contactsCount = await $$('.list-itemtype-user').count();

            await browser.sleep(3000);

            expect(contactsCount).to.be.above(0);
        });
    });
});
