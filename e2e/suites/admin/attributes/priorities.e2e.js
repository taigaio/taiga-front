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

describe('attributes - priorities', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-values/priorities');

        await adminAttributesHelper.waitLoad();

        utils.common.takeScreenshot('attributes', 'priorities');
    });

    it('new priority', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let count = await rows.count();

        let formWrapper = section.openNew();

        let form = adminAttributesHelper.getGenericForm(formWrapper);

        await form.name().sendKeys('test test');

        await form.save();

        await browser.waitForAngular();

        let newCount = await rows.count();

        expect(newCount).to.be.equal(count + 1);
    });

    it('delete', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();

        let count = await rows.count();

        let row = rows.get(count - 1);

        section.delete(row);

        let el = $('.lightbox-ask-choice');

        await utils.lightbox.open(el);

        utils.common.takeScreenshot('attributes', 'delete-priority');

        el.$('.button-green').click();

        await utils.lightbox.close(el);

        let newCount = await rows.count();

        expect(newCount).to.be.equal(count - 1);
    });

    it('edit', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let row = rows.get(0);

        await section.edit(row);

        let form = adminAttributesHelper.getGenericForm(row.$('form'));

        let newPriorityName = 'test test' + Date.now();
        await form.name().clear();
        await form.name().sendKeys(newPriorityName);

        await form.save();

        await browser.waitForAngular();

        let newPriorities = await adminAttributesHelper.getGenericNames(section.el);

        expect(newPriorities.indexOf(newPriorityName)).to.be.not.equal(-1);
    });

    it('drag', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let priorities = await adminAttributesHelper.getGenericNames(section.el);

        await utils.common.drag(rows.get(0), rows.get(2));

        let newPriorities = await adminAttributesHelper.getGenericNames(section.el);

        expect(priorities[0]).to.be.equal(newPriorities[1]);
    });
});
