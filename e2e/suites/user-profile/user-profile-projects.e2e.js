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

describe('user profile - projects', function() {
    describe('other user', function() {
        before(async function(){
            browser.get(browser.params.glob.host + '/profile/user7');

            await utils.common.waitLoader();

            $$('.tab').get(1).click();

            await browser.waitForAngular();

            utils.common.takeScreenshot('user-profile', 'other-user-projects');
        });

        it('projects tab', async function() {
            let projectsCount = await $$('.list-itemtype-project').count();

            expect(projectsCount).to.be.above(0);
        });
    });
});
