var profile = {
    resourceTags: {
        test: function (filename, mid) {
            return false;
        },
        amd: function (filename, mid) {
            return (/\.js$/).test(filename)
            && !((/\._.*\.js$/).test(filename)); //Exclude files starting with "._"
        }
    }
};