var argv = require('minimist')(process.argv.slice(2));
var child_process = require('child_process');
var inquirer = require("inquirer");
var Promise = require('bluebird');

var suites = [
    'auth',
    'public',
    'wiki',
    'admin',
    'issues',
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
    child_process.spawnSync('protractor', ['conf.e2e.js', '--suite=' + suit], {stdio: "inherit"});
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

launch();
