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

describe('change password', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'user-settings/user-change-password');
        await utils.common.waitLoader();

        utils.common.takeScreenshot('edit-user-profile', 'change-password');
    });

    beforeEach(async function() {
        browser.get(browser.params.glob.host + 'user-settings/user-change-password');

        await utils.common.waitLoader();
    });

    it('retype different', async function() {
        await $('#current-password').sendKeys('123123');
        await $('#new-password').sendKeys('123456');
        await $('#retype-password').sendKeys('000');

        $('.submit-button').click();

        let waitErrorOpen = await utils.notifications.error.open();

        expect(waitErrorOpen).to.be.ok;
    });

    it('incorrect current password', async function() {
        await $('#current-password').sendKeys('aaaa');
        await $('#new-password').sendKeys('123456');
        await $('#retype-password').sendKeys('123456');

        $('button[type="submit"]').click();

        let waitErrorOpen = await utils.notifications.error.open();

        expect(waitErrorOpen).to.be.ok;
    });

    it('change password', async function() {
        await $('#current-password').sendKeys('123123');
        await $('#new-password').sendKeys('aaabbb');
        await $('#retype-password').sendKeys('aaabbb');

        $('button[type="submit"]').click();

        let waitSuccessOpen = await utils.notifications.success.open();

        expect(waitSuccessOpen).to.be.ok;
    });

    after(async function() {
        browser.get(browser.params.glob.host + 'user-settings/user-change-password');
        await utils.common.waitLoader();

        //restore
        await $('#current-password').sendKeys('aaabbb');
        await $('#new-password').sendKeys('123123');
        await $('#retype-password').sendKeys('123123');

        $('button[type="submit"]').click();

        await utils.notifications.success.open();

        await browser.waitForAngular();
    });
});
