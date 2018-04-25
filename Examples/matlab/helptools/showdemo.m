function showdemo(fname)
%SHOWDEMO Open the HTML-file for a demo in the Help Browser.
%   SHOWDEMO(FNAME) locates the corresponding HTML-file for
%   the MATLAB file FNAME and opens it in the Help Browser.

% Copyright 2005-2015 The MathWorks, Inc.

% Make sure that java is supported for 1) the call to get the localized
% demo file and 2) the Help browser.
if ~usejava('swing')
    error(message('MATLAB:showdemo:UnsupportedPlatform'));
end

fname = char(fname);

% Find the .m file or .mdl files, including shadowed ones.
fileList = which('-all',fname);
if isempty(fileList)
    error(message('MATLAB:showdemo:NotFound',fname));
end

% See if any of these have a corresponding .html file.
htmlFile = '';
for iFileList = 1:numel(fileList)
    [demoDir,name] = fileparts(fileList{iFileList});
    html = fullfile(demoDir,'html',[name '.html']);
    htmlLoc = char(com.mathworks.mlwidgets.help.DemoInfoUtils.getLocalizedDemoFilename(html));

    % Redirect links to old demo pages to corresponding Examples
    % pages.
    [redirect,mapfile,topic] = helpUtils.checkForDemoRedirect(html);
    if redirect
        helpview(mapfile,topic)
        return

    elseif ~isempty(dir(htmlLoc))
        htmlFile = htmlLoc;
        break
    elseif ~isempty(dir(html))
        htmlFile = html;
        break
    end
end

% Display the results.
if isempty(htmlFile)
    error(message('MATLAB:showdemo:NotFound',[fname '.html']));
else
    web(htmlFile);
end
