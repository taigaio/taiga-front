require("babel/register")({
    stage: 1
});

var utils = require('./e2e/utils');

exports.config = {
    seleniumAddress: 'http://localhost:4444/wd/hub',
    framework: 'mocha',
    params: {
        glob: {
            host: 'http://localhost:9001/'
        }
    },
    mochaOpts: {
        timeout: 30000,
        compilers: 'js:babel/register'
    },
    // capabilities: {
    //     'browserName': 'firefox'
    // },
    suites: {
        auth: 'e2e/auth/*.e2e.js',
        full: 'e2e/full/**/*.e2e.js',
        public: 'e2e/public/**/*.e2e.js'
    },
    onPrepare: function() {
        browser.driver.manage().window().maximize();

        browser.getCapabilities().then(function (cap) {
            browser.browserName = cap.caps_.browserName;
        });

        browser.get(browser.params.glob.host + 'login');

        var username = $('input[name="username"]');
        username.sendKeys('admin');

        var password = $('input[name="password"]');
        password.sendKeys('123123');

        $('.submit-button').click();

        return browser.driver.wait(function() {
            return utils.common.closeCookies()
                .then(function() {
                    return browser.driver.getCurrentUrl();
                })
                .then(function(url) {
                    return url === browser.params.glob.host;
                });
        }, 10000)
        .then(function() {
            return browser.getCapabilities();
        }).then(function (cap) {
            browser.browserName = cap.caps_.browserName;
        });
    }
}
