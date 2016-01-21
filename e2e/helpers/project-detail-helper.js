var utils = require('../utils');

var helper = module.exports;

helper.lookingForPeople = function() {
    return $$('.looking-for-people input').get(0);
};

helper.lookingForPeopleReason = function() {
    return $$('.looking-for-people-reason input').get(0);
};

helper.toggleIsLookingForPeople = function() {
    helper.lookingForPeople().click();
};

helper.editLogo = function() {
    let inputFile = $('#logo-field');

    var fileToUpload = utils.common.uploadImagePath();

    return utils.common.uploadFile(inputFile, fileToUpload);
};

helper.getLogoSrc = function() {
    return $('.image-container .image');
};
