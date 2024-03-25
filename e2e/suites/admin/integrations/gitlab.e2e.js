/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../../utils');

var adminIntegrationsHelper = require('../../../helpers').adminIntegrations;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('admin - gitlab', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-3/admin/third-parties/gitlab');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('integrations', 'gitlab');
    });

    it('save', async function() {
        $('.submit-button').click();

        expect(utils.notifications.success.open()).to.be.eventually.true;
    });
});
