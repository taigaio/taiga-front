/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var serverData;

function alphabetical(a, b) {
    var A = a.toLowerCase();
    var B = b.toLowerCase();

    if (A < B){
        return -1;
    }else if (A > B){
        return  1;
    }else{
        return 0;
    }
}

$.get('get').then(function(data) {
    serverData = data;

    printSections(serverData);
});

$('.browsers .browser').click(function() {
    $(this).toggleClass('active');
});

$('.browsers .search').click(function() {
    var data = serverData;

    // filter by browser
    var activeBrowsers = [];

    $('.browsers .active').each(function() {
        activeBrowsers.push($(this).data('browser'));
    });

    data = data.filter(function(item) {
        return activeBrowsers.indexOf(item.browser) !== -1;
    });

    // filter by section
    var section = $('.browsers select').val();

    if (section !== 'all') {
        data = data.filter(function(item) {
            return item.section === section;
        });
    }

    if(!data.length) {
        alert('no images found');
        return;
    }

    data.sort(function(a, b) {
        return alphabetical(a.title, b.title);
    });

    initGallery(data);
});

function printSections(images) {
    var sections = [];

    var select = $('.browsers select');
    var options = [];

    var imagesSections = images.reduce(function(sections, image) {
        if (sections.indexOf(image.section) === -1) {
            sections.push(image.section);
        }

        return sections;
    }, []);

    imagesSections.forEach(function(section) {
        var option = $('<option>')
                .val(section)
                .text(section);

        select.append(option);
    });
}

function initGallery(images) {
    var pswpElement = document.querySelectorAll('.pswp')[0];

    var items = [];

    for(var i = 0; i < images.length; i++) {
        items.push({
            title: images[i].title + ' - ' + images[i].section +  ' - ' + images[i].browser,
            src: images[i].src,
            w: images[i].w,
            h: images[i].h
        });
    }

    var options = {
        index: 0,
        closeOnScroll: false
    };

    var gallery = new PhotoSwipe( pswpElement, PhotoSwipeUI_Default, items, options);

    gallery.init();
}
