/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

var utils = require('../../../utils');

var adminIntegrationsHelper = require('../../../helpers').adminIntegrations;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('admin - bitbucket', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-3/admin/third-parties/bitbucket');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('integrations', 'bitbucket');
    });

    it('save', async function() {
        $('.submit-button').click();

        expect(utils.notifications.success.open()).to.be.eventually.true;
    });
});
