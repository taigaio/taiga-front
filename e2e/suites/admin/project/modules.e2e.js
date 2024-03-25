/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('modules', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-profile/modules');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('admin', 'project-modules');

        // enable if the first module is disable
        let functionalities = $$('.module');
        let functionality = functionalities.get(0);

        let active = await utils.common.hasClass(functionality, 'active');

        if(!active) {
            let input = functionality.$('.check input');

            browser.actions()
                .mouseMove(input)
                .click()
                .perform();

            await utils.notifications.success.open();
            await utils.notifications.success.close();
        }
    });

    it('disable module', async function() {
        let functionalities = $$('.module');

        let functionality = functionalities.get(0);

        let input = functionality.$('.check input');

        browser.actions()
            .mouseMove(input)
            .click()
            .perform();

        let active = await utils.common.hasClass(functionality, 'active');

        await utils.notifications.success.open();

        expect(active).to.be.false;

        await utils.notifications.success.close();
    });

    it('enable module', async function() {
        let functionalities = $$('.module');

        let functionality = functionalities.get(0);

        let input = functionality.$('.check input');

        browser.actions()
            .mouseMove(input)
            .click()
            .perform();

        let notificationSuccess = await utils.notifications.success.open();

        expect(notificationSuccess).to.be.equal(true);

        let active = await utils.common.hasClass(functionality, 'active');

        expect(active).to.be.true;

        await utils.notifications.success.close();
    });

    it('enable videoconference', async function() {
        let functionality = $$('.module').get(5);

        let input = functionality.$('.check input');

        browser.actions()
            .mouseMove(input)
            .click()
            .perform();

        let videoconference = functionality.$$('select').get(0);

        videoconference.$(`option:nth-child(2)`).click();

        let salt = $('#videoconference-prefix');

        salt.sendKeys('abccceee');

        functionality.$('.save').click();

        let notificationSuccess = await utils.notifications.success.open();

        expect(notificationSuccess).to.be.equal(true);
    });
});
