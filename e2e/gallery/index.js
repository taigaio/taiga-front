/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var express = require('express');
var glob = require('glob');
var sizeOf = require('image-size');

var app = express();

app.set('views', './e2e/gallery');
app.set('view engine', 'jade');
app.use('/photoswipe', express.static('node_modules/photoswipe/dist'));
app.use('/e2e', express.static('./e2e/'));

var mapFiles = function(file) {
    var filePath = file.split('/');

    var title = filePath[filePath.length - 1].split('.')[0];
    var section = filePath[filePath.length - 2];
    var browser = filePath[2];

    var dimensions = sizeOf(file);

    return {
        title: title,
        section: section,
        browser: browser,
        src: file,
        w: dimensions.width,
        h: dimensions.height
    };
};

app.get('/get', function (req, res) {
    glob('e2e/screenshots/**/*.png', {}, function (er, files) {
        var filesMap = files.map(mapFiles);

        res.json(filesMap);
    });
});

app.get('/', function (req, res) {
    res.render('gallery', { title: 'Express' });
});

var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;
});
