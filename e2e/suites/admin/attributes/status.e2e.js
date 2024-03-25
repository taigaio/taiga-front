/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../../utils');

var adminAttributesHelper = require('../../../helpers').adminAttributes;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('attributes - status', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-values/status');

        await adminAttributesHelper.waitLoad();

        utils.common.takeScreenshot('attributes', 'status');
    });

    it('new status', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let count = await rows.count();

        let formWrapper = section.openNew();

        let form = adminAttributesHelper.getStatusForm(formWrapper);

        await form.status().sendKeys('test test');

        await form.save();

        await browser.waitForAngular();

        let newCount = await rows.count();

        expect(newCount).to.be.equal(count + 1);
    });

    it('duplicate status', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let count = await rows.count();

        let formWrapper = section.openNew();

        let form = adminAttributesHelper.getStatusForm(formWrapper);

        await form.status().sendKeys('test test');

        await form.save();

        await browser.waitForAngular();

        let newCount = await rows.count();

        let errors = await form.errors().count();

        utils.common.takeScreenshot('attributes', 'status-error');

        expect(errors).to.be.equal(1);
        expect(newCount).to.be.equal(count);
    });

    it('delete', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();

        let count = await rows.count();

        let row = rows.get(count - 1);

        section.delete(row);

        let el = $('.lightbox-ask-choice');

        await utils.lightbox.open(el);

        utils.common.takeScreenshot('attributes', 'delete-status');

        el.$('.button-green').click();

        await browser.waitForAngular();

        let newCount = await rows.count();

        expect(newCount).to.be.equal(count - 1);
    });

    it('edit', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();

        let row = rows.get(0);

        await section.edit(row);

        let form = adminAttributesHelper.getStatusForm(row.$('form'));

        let newStatusName = 'test test' + Date.now();

        await form.status().clear();
        await form.status().sendKeys(newStatusName);
        await form.save();

        await browser.waitForAngular();

        let newStatuses = await adminAttributesHelper.getStatusNames(section.el);

        expect(newStatuses.indexOf(newStatusName)).to.be.not.equal(-1);
    });

    it('drag', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let statuses = await adminAttributesHelper.getStatusNames(section.el);

        await utils.common.drag(rows.get(0), rows.get(2));

        let newStatuses = await adminAttributesHelper.getStatusNames(section.el);

        expect(statuses[0]).to.be.equal(newStatuses[1]);
    });
});
