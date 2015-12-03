require("babel/register")({
    stage: 1
});

var utils = require('./e2e/utils');

exports.config = {
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
        timeout: 45000,
        compilers: 'js:babel/register'
    },
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
        userStories: "e2e/suites/user-stories/*.e2e.js",
        backlog: "e2e/suites/backlog.e2e.js",
        home: "e2e/suites/home.e2e.js",
        kanban: "e2e/suites/kanban.e2e.js",
        projectHome: "e2e/suites/project-home.e2e.js",
        search: "e2e/suites/search.e2e.js",
        team: "e2e/suites/team.e2e.js"
    },
    onPrepare: function() {
        // track mouse movements
        var trackMouse = function() {
          angular.module('trackMouse', []).run(function($document) {

            function addDot(ev) {
              var color = 'black',
                size = 6;

              switch (ev.type) {
                case 'click':
                  color = 'red';
                  break;
                case 'dblclick':
                  color = 'blue';
                  break;
                case 'mousemove':
                  color = 'green';
                  break;
              }

              var dotEl = $('<div></div>')
                .css({
                  position: 'fixed',
                  height: size + 'px',
                  width: size + 'px',
                  'background-color': color,
                  top: ev.clientY,
                  left: ev.clientX,

                  'z-index': 9999,

                  // make sure this dot won't interfere with the mouse events of other elements
                  'pointer-events': 'none'
                })
                .appendTo('body');

              setTimeout(function() {
                dotEl.remove();
              }, 1000);
            }

            $document.on({
              click: addDot,
              dblclick: addDot,
              mousemove: addDot
            });

          });
        };
        browser.addMockModule('trackMouse', trackMouse);

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
            return utils.common.closeJoyride();
        })
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
