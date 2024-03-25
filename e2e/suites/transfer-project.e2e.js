/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');
var adminHelper = require('../helpers/project-detail-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('transfer project', () => {
    let projectSlug = '';
    before(async () => {
        projectSlug = await utils.common.createProject(['user5@taigaio.demo']);

        await utils.nav
            .init()
            .admin()
            .go();

        adminHelper.changeOwner();

        let lb = adminHelper.getChangeOwnerLb();

        await lb.waitOpen();

        lb.search('Angela Perez');
        lb.select(0);
        lb.addComment('text');

        lb.send();

        let changeOwnerSuccessLb = adminHelper.changeOwnerSuccessLb();

        await utils.lightbox.open(changeOwnerSuccessLb);

        changeOwnerSuccessLb.$('.button-green').click();

        await utils.lightbox.close(changeOwnerSuccessLb);

        await utils.common.logout();
        await utils.common.login('user5', '123123');
    });

    it('reject', async () => {
        let token = await utils.common.getTransferProjectToken(projectSlug, 'user5');

        browser.get(browser.params.glob.host + 'project/'+ projectSlug +'/transfer/' + token);

        await utils.common.waitLoader();

        utils.common.takeScreenshot('transfer-project', 'step1');

        $('.e2e-transfer-reject').click();

        let notificationSuccess = await utils.notifications.success.open();

        expect(notificationSuccess).to.be.true;
    });

    it('accept', async () => {
        let token = await utils.common.getTransferProjectToken(projectSlug, 'user5');

        browser.get(browser.params.glob.host + 'project/' + projectSlug + '/transfer/' + token);

        await utils.common.waitLoader();

        $('.e2e-transfer-accept').click();

        let notificationSuccess = await utils.notifications.success.open();

        expect(notificationSuccess).to.be.true;
    });

    it('restriction page', async () => {
        await utils.common.setUserLimits('user5', {
            max_private_projects: 0,
            max_memberships_private_projects: 0,
            max_public_projects: 0,
            max_memberships_public_projects: 0
        });

        let token = await utils.common.getTransferProjectToken(projectSlug, 'user5');

        browser.get(browser.params.glob.host + 'project/'+ projectSlug +'/transfer/' + token);

        await utils.common.waitLoader();

        utils.common.takeScreenshot('transfer-project', 'error');
    });
});
