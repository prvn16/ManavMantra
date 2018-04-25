classdef (Sealed, Abstract) AppScreenshot < handle
    %APPSCREENSHOT Helper functions for working with an app's screenshot
    %
    % Copyright 2017 The MathWorks, Inc.

    methods(Static)
        function capture(appFigure, appFullFileName)
            % CAPTURE - captures a screenshot of a running app and saves it
            %       in the app.

            % Find the CEF window for the running app's figure
            cefWindowList =  matlab.internal.webwindowmanager.instance.windowList;
            url = matlab.ui.internal.FigureServices.getFigureURL(appFigure);
            [idx] = arrayfun(@(ww)strcmp(url,ww.URL),cefWindowList);
            cefWindow = cefWindowList(idx);

            % Capture the screenshot
            im = cefWindow.getScreenshot;

            % Write the screenshot to the MLAPP file
            fileWriter = appdesigner.internal.serialization.FileWriter(appFullFileName);
            fileWriter.writeAppScreenshot(im);
        end

        function screenshotURI = getScreenshotURI(appFullFileName)
            % GETSCREENSHOTURI - gets the app screenshot contained in the
            %       MLAPP file and returns it as a base64 encoded data URI.
            %       Returns empty ([]) if the app has no screenshot.

            fileReader = appdesigner.internal.serialization.FileReader(appFullFileName);
            screenshotURI = fileReader.readAppScreenshot('uri');
        end
    end
end