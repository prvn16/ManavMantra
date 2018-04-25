function varargout=web(varargin)
%WEB Open Web site or file in Web browser.
%   WEB URL displays the specified URL in your web browser. The WEB function accepts
%   a valid URL such as a web site address or a relative path to a file.
%
%   Examples:
%      web http://www.mathworks.com
%         opens the MathWorks Web site home page.
%
%      web mydir/myfile.html
%         opens myfile.html in a browser, where mydir is in the current folder.
%
%      web /users/userId/mydir/myfile.html
%         opens myfile.html in a browser using an absolute path.
%
%      web(which('foo.html'));
%         opens the file foo.html if it is on the MATLAB path.
%
%   See also DOC.

%   Copyright 1984-2010 The MathWorks, Inc.

% Initialize defaults.
html_file = [];

if nargout > 0
    varargout = {0 [] ''};
end

for i = 1:length(varargin)
    argName = strtrim(varargin{i});
    if (strcmp(argName, '-browser') == 1 || ...
            strcmp(argName, '-new') == 1 || ...
            strcmp(argName, '-notoolbar') == 1 || ...
            strcmp(argName, '-noaddressbox') == 1 || ...
            strcmp(argName, '1') == 1)

        error(message('MATLAB:connector:Platform:FunctionArgumentsNotSupported', mfilename, argName));
    % Ignore the -helpbrowser flag (don't throw an error for backwards compatibility)
    elseif ~strcmp(argName, '-helpbrowser')
        % assume this is the filename.
        html_file = argName;
        if strncmp(html_file, docroot, numel(docroot))
            html_file = ['https://www.mathworks.com/help', html_file(numel(docroot)+1:end)];
        end
    end
end

if ~isempty(html_file)
    if length(html_file) < 7 || ~(startsWith(html_file, 'http://') || startsWith(html_file, 'https://'))
        % If the file is on MATLAB's search path, get the real filename.
        fullpath = which(html_file);
        if ~isempty(fullpath)
            % This means the file is on the path somewhere.
            html_file = fullpath;
        end
    end
end

% Handle matlab: protocol by passing the command to evalin.
if strncmp(html_file, 'matlab:', 7)
    evalin('caller', html_file(8:end));
    return;
end


% If no protocol specified, or an absolute/UNC pathname is not given,
% include explicit 'http:'.  Otherwise the web browser assumes 'file:'
if ~isempty(html_file) && isempty(findstr(html_file,':')) && ~strcmp(html_file(1:2),'\\') && ~strcmp(html_file(1),'/')
    if exist(html_file,'file')==0
        html_file = ['http://' html_file];
    else
        html_file = [pwd '/' html_file];
    end
end

if ~isempty(html_file)
    % Adding code to use pub-sub client as to publish message to web-gui project
    message.publish('/web/newtab', html_file);
else
    error(message('MATLAB:connector:Platform:UnsupportedURI'));
end
