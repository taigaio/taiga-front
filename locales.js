var glob = require('glob');
var inquirer = require('inquirer');
var fs = require('fs');
var _ = require('lodash');
var clc = require('cli-color');

var app = 'app/';

var question = {
    type: 'list',
    name: 'command',
    message: 'Action',
    choices: [
        {
            name: 'Replace keys',
            value: 'replace-keys'
        },
        {
            name: 'Find duplicates',
            value: 'find-duplicates'
        }
    ]
};

inquirer.prompt([question], function( answer ) {
    if (answer.command === 'replace-keys') replaceKeys();
    if (answer.command === 'find-duplicates') findDuplicates();
});

findDuplicates();

function replaceKeys() {
    question()
        .then(searchKey)
        .then(printFiles)
        .then(confirm)
        .then(replace);

    function question() {
        return new Promise(function (resolve, reject) {
            var questions = [
                {
                    type: 'input',
                    message: 'Write the key',
                    name: 'find_key'
                },
                {
                    type: 'input',
                    message: 'Write the new key',
                    name: 'replace_key'
                }
            ];

            inquirer.prompt(questions, function(answers) {
                resolve({
                    answers: answers,
                    files: []
                });
            });
        });
    }

    function searchKey(obj) {
        return new Promise(function (resolve, reject) {
            var key = obj.answers.find_key;

            glob(app + '**/*.+(jade|coffee)', {}, function (er, files) {
                obj.files = files.filter(function(filepath) {
                    var file = fs.readFileSync(filepath).toString('utf8');

                    return file.indexOf(key) !== -1;
                });

                resolve(obj);
            });
        });
    }

    function printFiles(obj) {
        return new Promise(function (resolve, reject) {
            obj.files.forEach(function(file) {
                console.log(file);
            });

            resolve(obj);
        });
    }

    function confirm(obj) {
        return new Promise(function (resolve, reject) {
            var questions = [
                {
                    type: 'confirm',
                    message: 'Are you sure?',
                    name: 'sure'
                }
            ];

            inquirer.prompt(questions, function(answer) {
                if (answer.sure) {
                    resolve(obj);
                } else {
                    reject('Cancel replace');
                }
            });
        });
    };

    function replace(obj) {
        obj.files.forEach(function(filepath) {
            var file = fs.readFileSync(filepath).toString('utf8');
            var re = new RegExp(obj.answers.find_key, 'g');

            file = file.replace(re, obj.answers.replace_key);

            fs.writeFile(filepath, file);
        });
    }
}


function findDuplicates() {
    glob(app + 'locales/taiga/*.json', {}, function (er, files) {
        console.log(files);
        files.forEach(duplicates);
    });

    function duplicates(file) {
        var fileKeys = flatKeys(file);
        var duplicates = [];
        var value = '';
        var values = _.values(fileKeys);

        for (key in fileKeys) {
            value = fileKeys[key];

            if(duplicates.indexOf(value) !== -1) continue;

            if (values.indexOf(value) !== values.lastIndexOf(value)) {
                duplicates.push(value);

                console.log(clc.red(value) + ' duplicate in ' + file);
            }
        }
    }

    function flatKeys(filepath) {
        var locale = JSON.parse(fs.readFileSync(filepath).toString('utf8'));
        return flatObject(locale);
    }
}


function flatObject(data, path) {
    var flat, keyWithPath, val;
    var result = {};

    if (!path) {
        path = [];
    }

    for (var key in data) {
        val = data[key];

        if (typeof val === 'object') {
            flat = flatObject(val, path.concat(key));

            _.assign(result, flat);
        } else {
            keyWithPath = path.length ? ("" + path.join(".") + "." + key) : key;
            result[keyWithPath] = val;
        }
    }

    return result;
};
