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

describe('reports', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/project-profile/reports');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('admin', 'project-reports');
    });

    it('generate report url', async function() {
        let reportField = $$('.csv-regenerate-field').get(0);

        reportField.$('a').click();

        await browser.waitForAngular();

        let value = await reportField.$('input').getAttribute('value');

        expect(value).to.have.length.above(1);
    });

    it('regenerate report url', async function() {
        let reportField = $$('.csv-regenerate-field').get(0);
        let oldValue = await reportField.$('input').getAttribute('value');

        reportField.$('a').click();

        await utils.lightbox.confirm.ok();

        await browser.waitForAngular();

        let value = await reportField.$('input').getAttribute('value');

        expect(value).not.to.be.equal(oldValue);
    });
});
