function outputPath = mdbpublish(file, format, evalcode, newfigure, ...
    displaycode, stylesheet, location, imagetype, screencapture, ...
    maxheight, maxwidth, thumbnailOn, maxOutputLines, codeToEvaluate, catchError)
%MDBPUBLISH   Helper function for the MATLAB Editor/Debugger that calls 
%   calls the Codepad publish function
%   
%   FILE name of file to publish
%   FORMAT one of the supported formats (html, xml, doc, ppt)
%   EVALCODE true if code should be evaluated
%   NEWFIGURE true if a new figure should be created
%   DISPLAYCODE true if code should be displayed in output
%   STYLESHEET path to custom stylesheet, or empty if default should be used
%   LOCATION path to save output in, or empty if default should be used
%   IMAGETYPE image filetype, one of the choices supported by IMWRITE or
%       default to use the default image type specified by publish
%   SCREENCAPTURE true if screen capture should be used, false if print
%   MAXHEIGHT -1 if height should not be restricted, otherwise max height
%   MAXWIDTH -1 if width should not be restricted, otherwise max width
%   THUMBNAILON true if thumbnail image should be created in output directory
%   MAXOUTPUTLINES -1 if output lines should not be restricted, otherwise
%       an integer specifying the maximum number of output lines before 
%       truncation of output
%   CODETOEVALUATE the code that should be evaluate by publish
%
%   Copyright 1984-2012 The MathWorks, Inc. 

options.format = format;
options.evalCode = evalcode;
options.useNewFigure = newfigure;
options.showCode = displaycode;
options.stylesheet = stylesheet;
options.codeToEvaluate = codeToEvaluate;
options.catchError = catchError;

if ~isequal(location, '')
    options.outputDir = location;
end

if ~isequal(imagetype, ...
        char(com.mathworks.mlwidgets.configeditor.data.PublishOptions.DEFAULT_IMAGE_TYPE))
    options.imageFormat = imagetype;
end
options.createThumbnail = thumbnailOn;
options.figureSnapMethod = screencapture;
if (maxheight ~= -1)
   options.maxHeight = maxheight;
end
if (maxwidth ~= -1)
   options.maxWidth = maxwidth;
end
if (maxOutputLines ~= -1)
    options.maxOutputLines = maxOutputLines;
end

outputPath = publish(file, options);
