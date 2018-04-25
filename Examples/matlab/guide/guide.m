function varargout=guide(varargin)
%GUIDE  Open the GUI Design Environment.
%   GUIDE initiates the GUI Design Environment(GUIDE) tools that allow GUIs
%   to be created or edited interactively from FIG-files or handle(s) to
%   figure.     
%
%   Calling GUIDE by itself will open the GUIDE Quick Start Dialog where
%   you can choose to open a previously created GUI or create a new one
%   from one of the provided GUI templates. 
%   
%   GUIDE(filename) opens the FIG-file named 'filename' for editing if it
%   is on the MATLAB path. GUIDE(fullpath) opens the FIG-file at 'fullpath'
%   even if it is not on the MATLAB path. 
%
%   GUIDE(HandleList) opens the content of each of the figures in
%   HandleList in a separate copy of the GUIDE design environment.  
%     
%   See also INSPECT.

%   GUIDE(..., '-test') allows internal MathWorks automated tests to run.

%   Copyright 1984-2011 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end


% error out if there is insufficient java support on this platform
errormsg = javachk('swing', 'GUIDE');
if ~isempty(errormsg)
    error(message('MATLAB:guide:NoSwingSupport', errormsg.message));
end

locNargin = nargin;
if nargin 
    if (isequal(varargin{end}, '-test')) 
        setappdata(0, 'MathWorks_GUIDE_testmode',1); 
        locNargin = locNargin - 1; 
    elseif (isequal(varargin{end}, '-testsave')) 
        setappdata(0, 'MathWorks_GUIDE_testmode',2); 
        locNargin = locNargin - 1; 
    else 
        if isappdata(0,'MathWorks_GUIDE_testmode') 
            rmappdata(0,'MathWorks_GUIDE_testmode'); 
        end 
    end 
else
    if isappdata(0,'MathWorks_GUIDE_testmode')
        rmappdata(0,'MathWorks_GUIDE_testmode');
    end
end

% Guarantee no more than one arguments left after handling 
% arguments by previous checking -test and -testsave options
if locNargin > 1
    error(message('MATLAB:guide:TooManyInputs'));
end

% This chunk of code initializes filename to:
%  - an empty string  (blank gui)
%  - a valid filename (open it)
%  - zero             (cancel)l
if getappdata(0, 'MathWorks_GUIDE_testmode')
    if (locNargin>0 && ischar(varargin{1}))
        filename = varargin{1};
    else
        filename = '';
    end
elseif locNargin == 0      
    if nargout==0
        % When output is not expected, guidetemplate will use the startup
        % optimization by creating an extra invisible LayoutEditor. It will
        % then call guide.m again with the user selection in the
        % QuickStartDialog 
        guidetemplate;
        return;
    else
        % When output is expected, guidetemplate will not use the startup
        % optimization. It returns an empty string or a legit filename on 
        % success. If the result is zero, the user hit cancel.   
        filename = guidetemplate;
        if isequal(filename,0)
            varargout{1} = [];
            return;
        elseif ishandle(filename)
            varargin{1} = filename;
        else
            % filename should be a char array
        end
    end
elseif ischar(varargin{1})
    % open specified filename
    filename = varargin{1};
else
    % set filename to zero for testing later
    filename = 0;
end

% We want to pass a filename with a fully specified path to the java code.
% Be prepared to handle two other cases
%
% 1) a file name specified w/o a .fig extension
%   (just append it)
% 2) a file name specified w/o a path
%   (prepend the path by using WHICH to find the file in the current
%    directory or on the path)
%
% After prepending the path and/or apending the extension, use EXIST to
% confirm that it is a legitimate file.

% handle the special case of guide(0) which was legal in R11
if isempty(filename) || (locNargin>0 && isequal(varargin{1}, 0))
    % Open an untitled layout editor.
    result = com.mathworks.toolbox.matlab.guide.LayoutEditor.newLayoutEditor;
elseif ischar(filename)
    [path,file,ext] = fileparts(filename);

    % Append the .fig extension if necessary
    if isempty(ext), ext = '.fig'; end

    if ~strcmp(ext, '.fig')
        error(message('MATLAB:guide:InvalidFileExtension', filename));
    end

    % Try to open a fig file.
    filename = fullfile(path, [file ext]);

    % Prepend the path if necessary
    savedname = filename;
    if isempty(path)
        filename = which(filename);
    end

    % Make sure it exists before opening the layout editor
    if ~exist(filename, 'file')
        error(message('MATLAB:guide:InvalidFileName', savedname));
    end
    
    result = com.mathworks.toolbox.matlab.guide.LayoutEditor.openLayoutEditor(filename);
else
    % Try to clone figures based on given handles.
    % shape input argument into a row vector
    figs = varargin{1}; figs = figs(:)';

    % verify that they are all figure handles
    if any(~ishandle(figs)) ||...
            length(figs) ~= length(strmatch('figure',get(figs,'type'),'exact'))
        error(message('MATLAB:guide:InvalidFigureHandle'));
    end

    result = cell(length(figs));
    for i=1:length(figs)
        result{i} = com.mathworks.toolbox.matlab.guide.LayoutEditor.openLayoutEditor(double(figs(i)));
    end

    % XXX what is the definition of "result"?
    result = result{1};
end

if nargout
    varargout{1} = result;
end
