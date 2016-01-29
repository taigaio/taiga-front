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
            discoverHelper.rearrangeLike(3);

            let filterText = await discoverHelper.getLikeFilterText();
            let projects = discoverHelper.likedProjects();

            expect(filterText).to.be.equal('All time');
            expect(await projects.count()).to.be.equal(5);

        });
    });

    describe('most active', () => {
        it('has projects', async () => {
            let projects = discoverHelper.activeProjects();

            expect(await projects.count()).to.be.above(0);
        });

        it('rearrange', async () => {
            discoverHelper.rearrangeActive(3);

            let filterText = await discoverHelper.getActiveFilterText();
            let projects = discoverHelper.activeProjects();

            expect(filterText).to.be.equal('All time');
            expect(await projects.count()).to.be.equal(5);
        });
    });

    it('featured projects', async () => {
        let projects = discoverHelper.featuredProjects();

        expect(await projects.count()).to.be.above(0);
    });
});
