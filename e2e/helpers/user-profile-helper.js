var helper = module.exports;

helper.getProjectsNames = function() {
    return $$('.list-itemtype-project-name').getText();
};

helper.waitLoader = function() {
    return browser.wait(function() {
        return $('.spin').isPresent();
    }, 5000);
};
