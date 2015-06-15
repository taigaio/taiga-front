var utils = require('./integration/utils');

exports.config = {
    seleniumAddress: 'http://localhost:4444/wd/hub',
    framework: 'mocha',
    mochaOpts: {
        timeout: 5000
    },
    suites: {
        auth: 'integration/auth/*.integrationSpec.js',
        full: 'integration/full/**/*integrationSpec.js'
    },
    onPrepare: function() {
        browser.get('http://localhost:9001/login');

        var username = $('input[name="username"]');
        username.sendKeys('admin');

        var password = $('input[name="password"]');
        password.sendKeys('123123');

        $('.submit-button').click();

        return browser.driver.wait(function() {
            return utils.common.closeCookies()
                .then(function() {
                    return browser.driver.getCurrentUrl()
                })
                .then(function(url) {
                    return url === 'http://localhost:9001/';
                });
        }, 10000);
    }
}
