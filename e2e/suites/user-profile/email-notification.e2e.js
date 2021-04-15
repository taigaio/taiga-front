/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
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
