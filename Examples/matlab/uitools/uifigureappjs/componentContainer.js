// Require browser compatability check lib
 require(["gbtclient/browsercheck"], function () {
     require(["mw-browser-utils/BrowserCheck!"], function () {
         // If the browser compatability check passes, require in the web widget lib
         require(["gbtclient/gbtclient"], function () {
            require([
                "dojo/io-query",
                "dojo/dom",
                "dojo/dom-class",
                "dijit/layout/ContentPane",
                "mw-messageservice/MessageService",
                "MW/componentframework/UIBuilderMLDriven",
                "gbtclient/ApplicationManifest",
                "dojo/domReady!"
                ], function (ioQuery, dom, domClass, ContentPane, MessageService, UIBuilderMLDriven, ApplicationManifest) {

                // Get query parameters
                var query, queryObject, url = location.href;
                query = url.substring(url.indexOf("?") + 1, url.length);
                queryObject = ioQuery.queryToObject(query);

                if (!queryObject) {
                    throw new Error("A peer model channel id was not provided as a query parameter!");
                }

                var contentPaneForFigure = new ContentPane({});
                contentPaneForFigure.placeAt("gbt_root_node").startup();
                domClass.add(contentPaneForFigure.domNode, "figureContentPane");

                var builder = new UIBuilderMLDriven({
                    "channel": queryObject.channel,
                    "applicationManifest": ApplicationManifest,
                    "rootWidget": contentPaneForFigure,
                    "environment": {}
                });
                MessageService.start();
            });
        });
    });
 });