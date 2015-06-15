var utils = require('../utils');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('auth', function() {
    it('login', function() {
        browser.get('http://localhost:9001/login');

        return utils.common.waitLoader().then(function() {
            utils.common.takeScreenshot("auth", "login");

            var username = $('input[name="username"]');
            username.sendKeys('admin');

            var password = $('input[name="password"]');
            password.sendKeys('123123');

            $('.submit-button').click();

            return expect(browser.getCurrentUrl()).to.be.eventually.equal('http://localhost:9001/');
        });
    });

    describe("user", function() {
        var user = {};

        describe("register", function() {
            it('screenshot', function() {
                browser.get('http://localhost:9001/register');

                utils.common.waitLoader().then(function() {
                    utils.common.takeScreenshot("auth", "register");
                });
            });

            it('register validation', function() {
                browser.get('http://localhost:9001/register');

                $('.submit-button').click();

                utils.common.takeScreenshot("auth", "register-validation");

                return expect($$('.checksley-required').count()).to.be.eventually.equal(4);
            });

            it('register ok', function() {
                browser.get('http://localhost:9001/register');

                user.username = "username-" + Math.random();
                user.fullname = "fullname-" + Math.random();
                user.password = "passsword-" + Math.random();
                user.email = "email-" + Math.random() + "@taiga.io";

                $('input[name="username"]').sendKeys(user.username);
                $('input[name="full_name"]').sendKeys(user.fullname);
                $('input[name="email"]').sendKeys(user.email);
                $('input[name="password"]').sendKeys(user.password);

                $('.submit-button').click();

                return expect(browser.getCurrentUrl()).to.be.eventually.equal('http://localhost:9001/');
            });
        });

        describe("change password", function() {
            beforeEach(function(done) {
                utils.common.login(user.username, user.password).then(function() {
                    browser.get('http://localhost:9001/user-settings/user-change-password');
                    done();
                });
            });

            it("error", function() {
                $('#current-password').sendKeys('wrong');
                $('#new-password').sendKeys('123123');
                $('#retype-password').sendKeys('123123');

                $('.submit-button').click();

                return expect(utils.notifications.error.open()).to.be.eventually.equal(true);
            });

            it("success", function() {
                $('#current-password').sendKeys(user.password);
                $('#new-password').sendKeys(user.password);
                $('#retype-password').sendKeys(user.password);

                $('.submit-button').click();

                return expect(utils.notifications.success.open()).to.be.eventually.equal(true);
            });
        });

        describe("remember password", function() {
            beforeEach(function() {
                browser.get('http://localhost:9001/forgot-password');
            });

            it ("screenshot", function() {
                utils.common.waitLoader().then(function() {
                    utils.common.takeScreenshot("auth", "remember-password");
                });
            });

            it ("error", function() {
                $('input[name="username"]').sendKeys("xxxxxxxx");
                $('.submit-button').click();

                return expect(utils.notifications.errorLight.open()).to.be.eventually.equal(true);
            });

            it ("success", function() {
                $('input[name="username"]').sendKeys(user.username);
                $('.submit-button').click();

                return utils.lightbox.open('.lightbox-generic-success').then(function() {
                    utils.common.takeScreenshot('auth', 'remember-password-success');

                    $('.lightbox-generic-success .button-green').click();

                    return expect(utils.lightbox.close('.lightbox-generic-success')).to.be.eventually.equal(true);
                });
            });
        });

        describe("", function() {
            it("logout", function() {
                return utils.common.login(user.username, user.password)
                    .then(function() {
                        browser.actions().mouseMove($('div[tg-dropdown-user]')).perform();
                        $$('.dropdown-user li a').last().click();

                        return expect(browser.getCurrentUrl()).to.be.eventually.equal('http://localhost:9001/login');
                    })
            });

            it("delete account", function() {
                return utils.common.login(user.username, user.password)
                    .then(function() {
                        browser.get('http://localhost:9001/user-settings/user-profile');
                        $('.delete-account').click();

                        return utils.lightbox.open('.lightbox-delete-account');
                    })
                    .then(function() {
                        utils.common.takeScreenshot("auth", "delete-account");

                        $('#unsuscribe').click();
                        $('.lightbox-delete-account .button-green').click();

                        return expect(browser.getCurrentUrl())
                            .to.be.eventually.equal('http://localhost:9001/login');
                    });
            });
        });
    });
});
