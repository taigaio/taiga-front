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
        it('has projects', () => {
            let projects = discoverHelper.likedProjects();

            expect(projects.count()).to.be.eventually.above(0);
        });

        it('rearrange', () => {
            discoverHelper.rearrangeLike(3);

            let filterText = discoverHelper.getLikeFilterText();
            let projects = discoverHelper.likedProjects();

            expect(filterText).to.be.eventually.equal('All time');
            expect(projects.count()).to.be.eventually.equal(5);

        });
    });

    describe('most active', () => {
        it('has projects', () => {
            let projects = discoverHelper.activeProjects();

            expect(projects.count()).to.be.eventually.above(0);
        });

        it('rearrange', () => {
            discoverHelper.rearrangeActive(3);

            let filterText = discoverHelper.getActiveFilterText();
            let projects = discoverHelper.activeProjects();

            expect(filterText).to.be.eventually.equal('All time');
            expect(projects.count()).to.be.eventually.equal(5);
        });
    });

    it('featured projects', () => {
        let projects = discoverHelper.featuredProjects();

        expect(projects.count()).to.be.eventually.above(0);
    });
});
