function codeStrOut = grabcode(filename)
%MATLAB code published to HTML
%   GRABCODE(FILENAME) extracts the MATLAB code from FILENAME and opens it in the
%   Editor.
%
%   GRABCODE(URL) does the same for any URL.
%
%   OUT = GRABCODE(...) returns the code as a char array, rather than opening
%   the Editor.
%
%   See also PUBLISH.

%   Copyright 1984-2015 The MathWorks, Inc.

% Auto-detect if this is a URL by looking for :// pattern
if strfind(filename,'://')
    % filename is a URL
    fileStr = urlread(filename);
    encodingMatch = regexp(native2unicode(fileStr, 'US-ASCII'),'charset=([A-Za-z0-9\-\.:_])*','tokens','once');             %Detect charset in the file

    try
        native2unicode(255,char(encodingMatch));    %Validate encodingMatch is valid and supported
    catch
        encodingMatch= {};                           %If not valid, set it to empty
        % A warning msg can be added here if needed
    end
    
    if isempty(encodingMatch) 
        locale = feature('locale');
        encodingMatch{1} = locale.encoding;               % Set charset to default encoding if charset not found/invalid in the file
    end
    fileStr = urlread(filename, 'Charset', char(encodingMatch));     % Set charset to what is detected in the file
else 
    % filename is a file
    fileStr = file2char(filename);
end




% Normalize line endings.
fileStr = regexprep(fileStr, '\r\n?', '\n');

% Pull out M-code.
matches = regexp(fileStr,'##### SOURCE BEGIN #####\n(.*)\n##### SOURCE END #####','tokens','once');
codeStr = matches{1};
codeStr = strrep(codeStr,'REPLACE_WITH_DASH_DASH','--');

% Return M-code.
if nargout == 0
    matlab.desktop.editor.newDocument(codeStr);
else
    codeStrOut = codeStr;
end
