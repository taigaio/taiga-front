/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var discoverHelper = require('../../helpers/discover-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;


describe('discover', () => {
    before(async () => {
        browser.get(browser.params.glob.host + 'discover');
        await utils.common.waitLoader();
    });

    it('screenshot', async () => {
        await utils.common.takeScreenshot("discover", "discover-home");
    });

    describe('most liked', () => {
        it('has projects', async () => {
            let projects = discoverHelper.likedProjects();

            let projectCount = await projects.count();

            expect(projectCount).to.be.above(0);
        });

        it('rearrange', async () => {
            let projects = discoverHelper.likedProjects();
            let discoverCount = await projects.count();

            discoverHelper.rearrangeLike(3);

            let filterText = await discoverHelper.getLikeFilterText();

            expect(filterText).to.be.equal('All time');
            expect(await projects.count()).to.be.equal(discoverCount);

        });
    });

    describe('most active', () => {
        it('has projects', async () => {
            let projects = discoverHelper.activeProjects();

            expect(await projects.count()).to.be.above(0);
        });

        it('rearrange', async () => {
            let projects = discoverHelper.activeProjects();
            let discoverCount = await projects.count();

            discoverHelper.rearrangeActive(3);

            let filterText = await discoverHelper.getActiveFilterText();

            expect(filterText).to.be.equal('All time');
            expect(await projects.count()).to.be.equal(discoverCount);
        });
    });

    it('featured projects', async () => {
        let projects = discoverHelper.featuredProjects();

        expect(await projects.count()).to.be.above(0);
    });
});
