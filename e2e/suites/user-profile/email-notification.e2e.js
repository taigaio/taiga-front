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

describe('email notification', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'user-settings/mail-notifications');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('edit-user-profile', 'mail-notifications');
    });

    it('change project notification to all', async function() {
        let row = $$('.policy-table-row').get(1);

        row.$$('label').get(0).click();

        let notificationOpen = await utils.notifications.success.open();

        expect(notificationOpen).to.be.true;

        await utils.notifications.success.close();
    });

    it('change project notification to no', async function() {
        let row = $$('.policy-table-row').get(1);

        row.$$('label').get(2).click();

        let notificationOpen = await utils.notifications.success.open();

        expect(notificationOpen).to.be.true;

        await utils.notifications.success.close();
    });

    it('change project notification to only', async function() {
        let row = $$('.policy-table-row').get(1);

        row.$$('label').get(1).click();

        let notificationOpen = await utils.notifications.success.open();

        expect(notificationOpen).to.be.true;

        await utils.notifications.success.close();
    });
});
