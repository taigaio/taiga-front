/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('auth', function() {
    before(async function() {
        await utils.common.logout();
    });

    it('login', async function() {
        browser.get(browser.params.glob.host + 'login');

        await utils.common.waitLoader();

        utils.common.takeScreenshot("auth", "login");

        var username = $('input[name="username"]');
        username.sendKeys('admin');

        var password = $('input[name="password"]');
        password.sendKeys('123123');

        $('.submit-button').click();

        await utils.common.waitLoader();

        let url = await browser.getCurrentUrl();

        expect(url).to.be.equal(browser.params.glob.host);
    });

    describe('page without perms', function() {
        let path = 'project/project-4/';

        before(async function() {
            await utils.common.logout();
        });

        it("redirect to login", async function() {
            browser.get(browser.params.glob.host + path);

            await utils.common.waitLoader();

            let url = await browser.getCurrentUrl();

            expect(url).to.be.equal(browser.params.glob.host + 'login?unauthorized&next=' + encodeURIComponent('/' + path));
        });

        it("login redirect to the previous one", async function() {
            $('input[name="username"]').sendKeys('admin');
            $('input[name="password"]').sendKeys('123123');
            $('.submit-button').click();

            await utils.common.waitLoader();

            let url = await browser.getCurrentUrl();

            expect(url).to.be.equal(browser.params.glob.host + path);
        });
    });

    describe("user", function() {
        var user = {};

        before(async function() {
            await utils.common.logout();
        });

        it("logout", async function() {
            await utils.common.login('admin', '123123');

            browser.actions().mouseMove($('div[tg-dropdown-user]')).perform();
            $$('.dropdown-user li a').last().click();

            await utils.common.waitLoader();

            let url = await browser.getCurrentUrl();

            await browser.wait(async () => {
                return url === browser.params.glob.host + 'discover';
            }, 2000);
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

            it('register ok', async function() {
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

                await utils.common.waitLoader();

                let currentUrl = await browser.getCurrentUrl();

                expect(currentUrl).to.be.equal(browser.params.glob.host);

                browser.get(browser.params.glob.host + '/');

                await utils.common.waitLoader();
                await utils.common.closeJoyride();
            });
        });

        describe("change password", function() {
            it("error", async function() {
                browser.get(browser.params.glob.host + 'user-settings/user-change-password');
                await browser.waitForAngular();

                $('#current-password').sendKeys('wrong');
                $('#new-password').sendKeys('123123');
                $('#retype-password').sendKeys('123123');

                $('.submit-button').click();

                let open = await utils.notifications.error.open();
                expect(open).to.be.equal(true);
            });

            it("success", async function() {
                browser.get(browser.params.glob.host + 'user-settings/user-change-password');
                await browser.waitForAngular();

                $('#current-password').sendKeys(user.password);
                $('#new-password').sendKeys(user.password);
                $('#retype-password').sendKeys(user.password);

                $('.submit-button').click();

                let open = await utils.notifications.success.open();
                expect(open).to.be.equal(true);

                await utils.notifications.success.close();
            });
        });

        describe("remember password", function() {
            before(async function() {
                await utils.common.logout();
            });

            beforeEach(async function() {
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
            before(async function() {
                await utils.common.login(user.username, user.password);
            });

            it("delete", async function() {
                browser.get(browser.params.glob.host + 'user-settings/user-profile');
                $('.delete-account').click();

                await utils.lightbox.open('.lightbox-delete-account');

                utils.common.takeScreenshot("auth", "delete-account");

                $('.lightbox-delete-account .button-red').click();

                let url = await browser.getCurrentUrl();

                expect(url).to.be.equal(browser.params.glob.host + 'login');
            });
        });
    });
});
