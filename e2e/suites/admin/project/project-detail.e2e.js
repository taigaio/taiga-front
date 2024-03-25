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

var adminHelper = require('../../../helpers/project-detail-helper');

describe('project detail', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-profile/details');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('admin', 'project-detail');
    });

    it('edit tag, description and project settings', async function() {
        adminHelper.enableAddTags();

        let tag = $('.e2e-add-tag-input');

        tag.sendKeys('aaa');
        browser.actions().sendKeys(protractor.Key.ENTER).perform();

        tag.sendKeys('bbb');
        browser.actions().sendKeys(protractor.Key.ENTER).perform();

        let description = $('#project-description');

        description.sendKeys('test test');

        let privateProjectButton = $$('.trans-button').get(1);

        browser.actions()
            .mouseMove(privateProjectButton)
            .click()
            .perform();

        utils.common.takeScreenshot('admin', 'project-detail-filled');

        $('button[type="submit"]').click();

        expect(utils.notifications.success.open()).to.be.eventually.equal(true);

        await utils.notifications.success.close();
    });

    it('looking for people', async function() {
        let checked = !! await adminHelper.lookingForPeople().getAttribute('checked');

        if(checked) {
            adminHelper.toggleIsLookingForPeople();
        }

        adminHelper.toggleIsLookingForPeople();

        adminHelper.lookingForPeopleReason().sendKeys('looking for people reason');

        $('button[type="submit"]').click();

        checked = !! await adminHelper.lookingForPeople().getAttribute('checked');

        expect(checked).to.be.true;
        expect(utils.notifications.success.open()).to.be.eventually.equal(true);
    });

    it('receive feedback', async function() {
        let checked = !! await adminHelper.receiveFeedback().getAttribute('checked');

        if(!checked) {
            adminHelper.togglereceiveFeedback();
        }

        $('button[type="submit"]').click();

        checked = !! await adminHelper.receiveFeedback().getAttribute('checked');

        expect(checked).to.be.true;
        expect(utils.notifications.success.open()).to.be.eventually.equal(true);
    });

    it('edit logo', async function() {
        let imageContainer = $('.image-container');

        let htmlChanges = await utils.common.outerHtmlChanges(imageContainer);

        adminHelper.editLogo();

        await htmlChanges();

        let src = await adminHelper.getLogoSrc().getAttribute('src');

        expect(src).to.contains('upload-image-test.png');
    });

    it('request ownership', async function() {
        adminHelper.requestOwnership();

        await utils.lightbox.open(adminHelper.requestOwnershipLb());

        adminHelper.acceptRequestOwnership();

        let notificationSuccess = await utils.notifications.success.open();

        expect(notificationSuccess).to.be.true;
    });

    it('change ownership', async function() {
        await utils.common.createProject(['user5@taigaio.demo']);

        await utils.nav
            .init()
            .admin()
            .go();

        adminHelper.changeOwner();

        let lb = adminHelper.getChangeOwnerLb();

        await lb.waitOpen();

        let username = lb.getUserName(0);

        await lb.search(username);

        lb.select(0);
        lb.addComment('text');

        utils.common.takeScreenshot('admin', 'project-transfer-lb');

        lb.send();

        let changeOwnerSuccessLb = adminHelper.changeOwnerSuccessLb();

        await utils.lightbox.open(changeOwnerSuccessLb);

        changeOwnerSuccessLb.$('.button-green').click();

        await utils.lightbox.close(changeOwnerSuccessLb);
    });
});
