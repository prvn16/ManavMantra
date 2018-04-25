function filename = docpath(filename)
%DOCPATH Obtain the localized path to a file under docroot.
%   DOCPATH(FILENAME) Obtain the localized path to a FILENAME under docroot.
%   If FILENAME doesn't exist under the default localized folder, the
%   fallback folder will be checked.  If it doesn't exist in any of the
%   locations, the function will return the original FILENAME value.
%
%   For displaying help pages in the Help browser, use HELPVIEW.
%
%   This function is unsupported and may change at any time without notice.
%
%     Example:
%        docpath(fullfile(docroot,'matlab','ref','examples'))
%
%     See also HELPVIEW

%   Copyright 2009-2012 The MathWorks, Inc.

% Make sure that we can support the docpath command on this platform.
if ~usejava('jvm')
    error(message('MATLAB:docpath:UnsupportedPlatform'));
end

if ~ischar(filename) && ~(isstring(filename) && isscalar(filename))
    error(message('MATLAB:docpath:MustBeSingleString'));
end

% Normalize to '/'
filename = regexprep(filename,'\\','/');
if ~isempty(regexp(filename,'help/toolbox/.+?/examples','once')) || ...
   ~isempty(regexp(filename,'help/techdoc/.+?/examples','once'))  
    % For examples, localize only
    
    % Get locale
    locale = com.mathworks.mlwidgets.help.HelpPrefs.getDocLocale;
    
    if ~isempty(locale)
        % Check for localized file existence
        locfile = regexprep(filename,'/help/',['/help/' char(locale.toString()) '/']);
        if exist(locfile,'file') || exist(locfile,'dir')
            filename = locfile; 
        end
    end
else
    stringIn = isstring(filename);
    if stringIn
        filename = char(filename);
    end
    % Obtain the help path to a help file, taking into account localization.
    filename = char(com.mathworks.mlservices.MLHelpServices.getLocalizedFilename(filename));
    if stringIn
        filename = string(filename);
    end
end
