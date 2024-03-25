/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var argv = require('minimist')(process.argv.slice(2));
var child_process = require('child_process');
var inquirer = require("inquirer");
var Promise = require('bluebird');

// npm run e2e -- --s userStories, auth

var taigaBackPath = '';
var suites = [
    'auth',
    'public',
    'wiki',
    'admin',
    'issues',
    'epics',
    'tasks',
    'userProfile',
    'userStories',
    'backlog',
    'home',
    'kanban',
    'projectHome',
    'search',
    'team',
    'discover'
];

var lunchSuites = [];

if (argv.s) {
    suites = argv.s.split(',');
}

function backup() {
    child_process.spawnSync('pg_dump', ['-c', '-d', 'taiga', '-f', 'tmp/taiga.sql'], {stdio: "inherit"});
}

function launchProtractor(suit) {
    let protractorParams = ['conf.e2e.js', '--suite=' + suit, '--back=' + taigaBackPath];

    var discard = [
        "_",
        "s",
        "a",
        "b"
    ];

    for(var arg in argv) {
        if (discard.indexOf(arg) === -1) {
            if(typeof argv[arg] === 'boolean') {
                protractorParams.push('--' + arg);
            } else {
                protractorParams.push('--' + arg + "=" + argv[arg]);
            }
        }
    }

    child_process.spawnSync('protractor', protractorParams, {stdio: "inherit"});
}

function restoreBackup() {
    child_process.spawnSync('psql', ['-d', 'taiga', '-f', 'tmp/taiga.sql']);
}

function ask() {
    return new Promise(function(resolve) {
        if (argv.a && suites.length) {
            inquirer.prompt([{
                type: 'list',
                name: 'next',
                message: 'Launch ' + suites[0] + '?',
                default: 'Yes',
                choices: [
                    'Yes',
                    'No'
                ]
            }], function( answers ) {
                if(answers.next === 'Yes') {
                    resolve(true);
                } else {
                    resolve(false);
                }
            });
        } else if(suites.length) {
            resolve(true);
        } else {
            resolve(false);
        }
    });
}

async function launch () {
    backup();

    var next = true;

    while (next) {
        var suite = suites.shift();

        console.log('running: ' + suite);

        launchProtractor(suite);

        restoreBackup();

        next = await ask();
    }
}

if (argv.b) {
    taigaBackPath = argv.b;
    launch();
} else {
    inquirer.prompt([
        {
            type: 'string',
            name: 'back',
            message: 'Taiga back path'
        }
    ], function (answer) {
        taigaBackPath = answer.back;
        launch();
    });
}
