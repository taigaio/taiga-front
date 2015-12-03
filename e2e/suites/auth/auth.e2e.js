var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('auth', function() {
    it('login', async function() {
        browser.get(browser.params.glob.host + 'login');

        await utils.common.waitLoader();

        utils.common.takeScreenshot("auth", "login");

        var username = $('input[name="username"]');
        username.sendKeys('admin');

        var password = $('input[name="password"]');
        password.sendKeys('123123');

        $('.submit-button').click();

        expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host);
    });

    describe('page without perms', function() {
        let path = 'project/project-4/';

        before(function() {
            return utils.common.topMenuOption(6);
        });

        it("redirect to login", async function() {
            browser.get(browser.params.glob.host + path);

            expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + 'login?next=' + encodeURIComponent('/' + path));
        });

        it("login redirect to the previous one", async function() {
            $('input[name="username"]').sendKeys('admin');
            $('input[name="password"]').sendKeys('123123');
            $('.submit-button').click();

            expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + path);
        });
    });

    describe("user", function() {
        var user = {};

        before(function() {
            utils.common.login('admin', '123123');
        });

        it("logout", async function() {
            await utils.common.login('admin', '123123');

            browser.actions().mouseMove($('div[tg-dropdown-user]')).perform();
            $$('.dropdown-user li a').last().click();

            expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + 'login');
        });

        describe("register", function() {
            it('screenshot', async function() {
                browser.get(browser.params.glob.host + 'register');

                await utils.common.waitLoader();

                utils.common.takeScreenshot("auth", "register");
            });

            it('register validation', function() {
                browser.get(browser.params.glob.host + 'register');

                $('.submit-button').click();

                utils.common.takeScreenshot("auth", "register-validation");

                expect($$('.checksley-required').count()).to.be.eventually.equal(4);
            });

            it('register ok', function() {
                browser.get(browser.params.glob.host + 'register');

                user.username = "username-" + Math.random();
                user.fullname = "fullname-" + Math.random();
                user.password = "passsword-" + Math.random();
                user.email = "email-" + Math.random() + "@taiga.io";

                $('input[name="username"]').sendKeys(user.username);
                $('input[name="full_name"]').sendKeys(user.fullname);
                $('input[name="email"]').sendKeys(user.email);
                $('input[name="password"]').sendKeys(user.password);

                $('.submit-button').click();

                expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host);
            });
        });

        describe("change password", function() {
            beforeEach(async function() {
                await utils.common.login(user.username, user.password);

                browser.get(browser.params.glob.host + 'user-settings/user-change-password');
            });

            it("error", function() {
                $('#current-password').sendKeys('wrong');
                $('#new-password').sendKeys('123123');
                $('#retype-password').sendKeys('123123');

                $('.submit-button').click();

                expect(utils.notifications.error.open()).to.be.eventually.equal(true);
            });

            it("success", function() {
                $('#current-password').sendKeys(user.password);
                $('#new-password').sendKeys(user.password);
                $('#retype-password').sendKeys(user.password);

                $('.submit-button').click();

                expect(utils.notifications.success.open()).to.be.eventually.equal(true);
            });
        });

        describe("remember password", function() {
            beforeEach(function() {
                browser.get(browser.params.glob.host + 'forgot-password');
            });

            it ("screenshot", async function() {
                await utils.common.waitLoader();

                utils.common.takeScreenshot("auth", "remember-password");
            });

            it ("error", function() {
                $('input[name="username"]').sendKeys("xxxxxxxx");
                $('.submit-button').click();

                expect(utils.notifications.errorLight.open()).to.be.eventually.equal(true);
            });

            it ("success", async function() {
                $('input[name="username"]').sendKeys(user.username);
                $('.submit-button').click();

                await utils.lightbox.open('.lightbox-generic-success');

                utils.common.takeScreenshot('auth', 'remember-password-success');

                $('.lightbox-generic-success .button-green').click();

                await utils.lightbox.close('.lightbox-generic-success');
            });
        });

        describe("accout", function() {
            before(function() {
                utils.common.login(user.username, user.password);
            });

            it("delete", async function() {
                browser.get(browser.params.glob.host + 'user-settings/user-profile');
                $('.delete-account').click();

                await utils.lightbox.open('.lightbox-delete-account');

                utils.common.takeScreenshot("auth", "delete-account");

                $('.lightbox-delete-account .button-green').click();

                expect(browser.getCurrentUrl()).to.be.eventually.equal(browser.params.glob.host + 'login');
            });
        });
    });
});
