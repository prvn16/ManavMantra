// Regex to tell build not to search CVS folders
var excludeCvsPaths = [[ ".", ".", /(\/\.)|(~$)|(CVS)/ ]];

var webWidgetBasePath = "../../../../ui/webwidgets/src/";

var profile = {
    // The location of top level packages declared as dependencies in the UI
    // code. You'll see these in the AMD define() function. For example:
    //      define(["dojo/store/Memory", "dijit/Dialog", "mw-log/Log"], function(...
    packages: [{
            name: "matlab_login",
            location: "matlab_login",
            // Exclude CVS folders from scanning
            trees: excludeCvsPaths
        },{
			name: "InstallServiceHandler",
			location: "../../../../ui/install/installservicehandler/InstallServiceHandler",
			trees: excludeCvsPaths
		}
	],

    // The JavaScript code will get minimized into layer files. dojo generates
    layers: {
        "matlab_login/matlab_login": {
            copyright: "copyright.txt",
            include: [
              // Add your main application modules first
              "matlab_login/LoginServiceIdentifiers",
			  "matlab_login/matlab_login",
			  "matlab_login/LoginStatusUpdate",
              "InstallServiceHandler/InstallServiceHandler",
			  "dojo/aspect",
			  "mw-messageservice/MessageService"
            ],
            exclude: [
              "matlab_login/browsercheck"
            ]
        }
    },
    localeList: 0,
    staticHasFeatures:{
        'dojo-preload-i18n-Api':0,
        'dojo-v1x-i18n-Api':0
    }
 
};
