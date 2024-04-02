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

describe('attributes - points', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-values/points');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('attributes', 'points');
    });

    it('new', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let count = await rows.count();

        let formWrapper = section.openNew();

        let form = adminAttributesHelper.getPointsForm(formWrapper);

        await form.name().sendKeys('test test');
        await form.value().sendKeys('2');

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

        utils.common.takeScreenshot('attributes', 'delete-point');

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

        let form = adminAttributesHelper.getPointsForm(row.$('form'));

        let newStatusName = 'test test' + Date.now();

        await form.name().clear();
        await form.name().sendKeys(newStatusName);
        await form.save();

        await browser.waitForAngular();

        let newStatuses = await adminAttributesHelper.getPointsNames(section.el);

        expect(newStatuses.indexOf(newStatusName)).to.be.not.equal(-1);
    });

    it('drag', async function() {
        let section = adminAttributesHelper.getSection(0);
        let rows = section.rows();
        let points = await adminAttributesHelper.getPointsNames(section.el);

        await utils.common.drag(rows.get(0), rows.get(2));

        let newPoints = await adminAttributesHelper.getPointsNames(section.el);

        expect(points[0]).to.be.equal(newPoints[1]);
    });
});
