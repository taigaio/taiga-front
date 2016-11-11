require("babel-register");
require("babel-polyfill");

var utils = require('./e2e/utils');
var argv = require('minimist')(process.argv.slice(2));

var config = {
    seleniumAddress: 'http://localhost:4444/wd/hub',
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
        timeout: 55000,
        compilers: 'js:babel-register',
        require: 'babel-polyfill'
    },
    // capabilities: {
    //     'browserName': 'firefox'
    // },
    // capabilities: {
    //     browserName: 'internet explorer',
    //     version: '11'
    // },
    suites: {
        auth: "e2e/suites/auth/*.e2e.js",
        public: "e2e/suites/public/**/*.e2e.js",
        wiki: "e2e/suites/wiki.e2e.js",
        admin: "e2e/suites/admin/**/*.e2e.js",
        issues: "e2e/suites/issues/*.e2e.js",
        tasks: "e2e/suites/tasks/*.e2e.js",
        userProfile: "e2e/suites/user-profile/*.e2e.js",
        epics: "e2e/suites/epics/*.e2e.js",
        userStories: "e2e/suites/user-stories/*.e2e.js",
        backlog: "e2e/suites/backlog.e2e.js",
        home: "e2e/suites/home.e2e.js",
        kanban: "e2e/suites/kanban.e2e.js",
        projectHome: "e2e/suites/project-home.e2e.js",
        search: "e2e/suites/search.e2e.js",
        team: "e2e/suites/team.e2e.js",
        discover: "e2e/suites/discover/*.e2e.js",
        createProject: "e2e/suites/create-project/*.e2e.js",
        transferProject: "e2e/suites/transfer-project.e2e.js",
        compileModules: "app/modules/compile-modules/**/*.e2e.js"
    },
    onPrepare: function() {
        // disable by default because performance problems on IE
        // track mouse movements
        // var trackMouse = function() {
        //   angular.module('trackMouse', []).run(function($document) {

        //     function addDot(ev) {
        //       var color = 'black',
        //         size = 6;

        //       switch (ev.type) {
        //         case 'click':
        //           color = 'red';
        //           break;
        //         case 'dblclick':
        //           color = 'blue';
        //           break;
        //         case 'mousemove':
        //           color = 'green';
        //           break;
        //       }

        //       var dotEl = $('<div></div>')
        //         .css({
        //           position: 'fixed',
        //           height: size + 'px',
        //           width: size + 'px',
        //           'background-color': color,
        //           top: ev.clientY,
        //           left: ev.clientX,

        //           'z-index': 9999,

        //           // make sure this dot won't interfere with the mouse events of other elements
        //           'pointer-events': 'none'
        //         })
        //         .appendTo('body');

        //       setTimeout(function() {
        //         dotEl.remove();
        //       }, 1000);
        //     }

        //     $document.on({
        //       click: addDot,
        //       dblclick: addDot,
        //       mousemove: addDot
        //     });

        //   });
        // };
        // browser.addMockModule('trackMouse', trackMouse);

        browser.params.glob.back = argv.back;

        require('./e2e/capabilities.js');

        browser.get(browser.params.glob.host);

        browser.executeScript('window.sessionStorage.clear();');
        browser.executeScript('window.localStorage.clear();');
        browser.executeScript('window.localStorage.e2e = true');

        browser.driver.manage().window().maximize();

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
            return utils.common.closeJoyride();
        })
        .then(function() {
            return browser.get(browser.params.glob.host);
        });
    }
};


if (argv.json) {
    var fs = require('fs');
    var dir = './e2e/reports';

    if (!fs.existsSync(dir)){
        fs.mkdirSync(dir);
    }

    var suites = argv.suite.split(',').join('-');

    var reportFileName = 'report-' + suites + '-chrome.json';

    if (argv.firefox) {
        reportFileName = 'report-' + suites + '-firefox.json';
    } else if (argv.ie) {
        reportFileName = 'report-' + suites + '-ie.json';
    }

    process.env['MOCHA_REPORTER'] = 'JSON';
    process.env['MOCHA_REPORTER_FILE'] = 'e2e/reports/' + reportFileName;

    config.mochaOpts.reporter = 'reporter-file';
}

if (argv.firefox) {
    config.capabilities = {
         browserName: 'firefox'
    };
}

if (argv.ie) {
    config.capabilities = {
         browserName: 'internet explorer',
         version: '11'
    };
}

if (argv.seleniumAddress) {
    config.seleniumAddress = argv.seleniumAddress;
}


if (argv.host) {
    config.params.glob.host = argv.host;
}

exports.config = config;
