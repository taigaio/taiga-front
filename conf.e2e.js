require("babel/register")({
    stage: 1
});

var utils = require('./e2e/utils');
var HtmlReporter = require('protractor-html-screenshot-reporter');

exports.config = {
    seleniumAddress: 'http://10.8.1.194:4444/wd/hub',
    framework: 'mocha',
    params: {
        glob: {
            host: 'http://localhost:9001/',
            attachments: {
                unix: './upload-file-test.txt',
                windows: 'C:\\test\\upload-file-test.txt',
                unixImg: './upload-image-test.png',
                windowsImg: 'C:\\test\\upload-image-test.png'
            }
        }
    },
    mochaOpts: {
        timeout: 30000,
        compilers: 'js:babel/register'
    },
    // capabilities: {
    //     browserName: 'internet explorer',
    //     version: '11'
    // },
    suites: {
        auth: "e2e/auth/*.e2e.js",
        public: "e2e/public/**/*.e2e.js",
        wiki: "e2e/full/wiki.e2e.js",
        admin: "e2e/full/admin/**/*.e2e.js",
        issues: "e2e/full/issues/*.e2e.js",
        tasks: "e2e/full/tasks/*.e2e.js",
        userProfile: "e2e/full/user-profile/*.e2e.js",
        userStories: "e2e/full/user-stories/*.e2e.js",
        backlog: "e2e/full/backlog.e2e.js",
        home: "e2e/full/home.e2e.js",
        kanban: "e2e/full/kanban.e2e.js",
        projectHome: "e2e/full/project-home.e2e.js",
        search: "e2e/full/search.e2e.js",
        team: "e2e/full/team.e2e.js"
    },
    onPrepare: function() {
        require('./e2e/capabilities.js');

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
        })
        .then(function() {
            return browser.get(browser.params.glob.host);
        });
    }
}
