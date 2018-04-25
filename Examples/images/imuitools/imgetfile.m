function [filename,userCanceled] = imgetfile(varargin)
%IMGETFILE Open Image dialog box.  
%   [FILENAME, USER_CANCELED] = IMGETFILE displays the Open Image dialog
%   box for the user to fill in and returns the full path to the file
%   selected in FILENAME. If the user presses the Cancel button,
%   USER_CANCELED will be TRUE. Otherwise, USER_CANCELED will be FALSE.
%
%   [FILENAME, USER_CANCELED] = IMGETFILE(..., Name, Value) specifies
%   additional name-value pairs described below:
%
%   'InitialPath'    A character vector used to specify the location where
%                    the interface will be launched. If initial path is not
%                    provided, the interface will be launched at the last
%                    location where an image was successfully selected. 
% 
%                    Default: no initial path provided
% 
%   'MultiSelect'    A boolean scalar or a string used to specify the
%                    selection mode.  The value of true or 'on' turns 
%                    multiple selection on, and value of false or 'off' 
%                    turns multiple selection off. If multiple selection is
%                    turned on, the output parameter FILENAME is a cell
%                    array of strings containing the full paths to the
%                    selected files.
%                   
%                    Default: false
%   
%   The Open Image dialog box is modal; it blocks the MATLAB command line
%   until the user responds. The file types listed in the dialog are all
%   formats listed in IMFORMATS plus DICOM.
%   
%   See also IMFORMATS, IMTOOL, IMPUTFILE, UIGETFILE.

%   Copyright 2003-2017 The MathWorks, Inc.

args = matlab.images.internal.stringToChar(varargin);

[initialPath, useMultiSelect] = parseInputs(args{:});

persistent cached_path;

% Create file chooser if necessary;
need_to_initialize_path = isempty(cached_path);
if need_to_initialize_path
    cached_path = '';
end

% Get filter spec for image formats
filterSpec = createImageFilterSpec();

% Form string 'Get Image' vs. 'Get Images' based on whether or not MultiSelect
% is enabled.
multiSelect = strcmp(useMultiSelect,'on');
if multiSelect
    dialogTitle = getString(message('images:fileGUIUIString:getFilesWindowTitle'));
else
    dialogTitle = getString(message('images:fileGUIUIString:getFileWindowTitle'));
end

if(isempty(initialPath))
    [fname,pathname,filterindex] = uigetfile(filterSpec,...
                                dialogTitle,...
                                cached_path,...
                                'MultiSelect',useMultiSelect);
else
    [fname,pathname,filterindex] = uigetfile(filterSpec,...
                                dialogTitle,...
                                initialPath,...
                                'MultiSelect',useMultiSelect);
end

% If user successfully chose file, cache the path so that we can open the
% dialog in the same directory the next time imgetfile is called.
userCanceled = (filterindex == 0);
if ~userCanceled
    
    % uigetfile switches between string and cell array output in
    % 'MultiSelect' mode depending on whether the user selects one file or
    % more than one file. We want imgetfile to always return a cell array
    % when 'MultiSelect' is true to provide a consistent interface for
    % clients.
    if multiSelect && ischar(fname)
        fname = {fname};
    end
        
    cached_path = pathname;
    filename = fullfile(pathname,fname);
else
    % If user cancelled, return empty {} or empty string depending on
    % MultiSelect state.
    if multiSelect
        filename = {};
    else
        filename = '';
    end
end


%--------------------------------------------------------------------------
function filterSpec = createImageFilterSpec()
% Creates filterSpec argument expected by uigetfile

% Generate filterSpec cell array
[desc, ext] = iptui.parseImageFormats();
nformats = length(desc);
filterSpec = cell([nformats+2,2]);

% Create "All Image Files" and "All Files" options
filterSpec{1,2} = 'All Image Files';
filterSpec{nformats+2,1} = '*.*';
filterSpec{nformats+2,2} = 'All Files (*.*)';

for i = 1:nformats
    thisExtension = ext{i};
    numExtensionVariants = length(thisExtension);
    thisExtensionString = strcat('*.',thisExtension{1});
    for j = 2:numExtensionVariants
        thisExtensionString = strcat(thisExtensionString,';*.',thisExtension{j});
    end
    
    % Add current extension to "All Images" list
    if (i==1)
        filterSpec{1,1} = thisExtensionString;
    else
        filterSpec{1,1} = strcat(thisExtensionString,';',filterSpec{1,1});
    end
    % Populate individual file extension and descriptions
    filterSpec{i+1,1} = thisExtensionString;
    filterSpec{i+1,2} = strcat(desc{i},' (',thisExtensionString,')');
end

%--------------------------------------------------------------------------
function [initialPath, useMultiSelect] = parseInputs(varargin)

% Check the maximum and minimum number of arguments
narginchk(0, 4);

if nargin > 0
    validatestring(varargin{1},{'InitialPath','MultiSelect'},mfilename,'TYPE',1);
    if nargin > 2
        validatestring(varargin{3},{'InitialPath','MultiSelect'},mfilename,'TYPE',3);
    end
end


% parameter parsing
parser = inputParser;
parser.addParameter('InitialPath','',@isValidPath);
parser.addParameter('MultiSelect', false, @checkMultiSelect);
parser.parse(varargin{:});

useMultiSelect = parser.Results.MultiSelect;
initialPath = parser.Results.InitialPath;

if isnumeric(parser.Results.MultiSelect) || islogical(parser.Results.MultiSelect)
    if (parser.Results.MultiSelect)
        useMultiSelect = 'on';
    else
        useMultiSelect = 'off';
    end
end

%--------------------------------------------------------------------------
function tf = checkMultiSelect(useMultiSelect)
tf = true;
validateattributes(useMultiSelect, {'logical', 'numeric', 'char'}, ...
    {'vector', 'nonsparse'}, ...
    mfilename, 'MultiSelect');
if ischar(useMultiSelect)
    validatestring(useMultiSelect, {'on', 'off'}, mfilename, 'UseMultiSelect');
else
    validateattributes(useMultiSelect, {'logical', 'numeric'}, {'scalar'}, ...
        mfilename, 'MultiSelect');
end

%--------------------------------------------------------------------------
function tf = isValidPath(initialPath)
validateattributes(initialPath, {'char'}, ...
    {'nonsparse'}, ...
    mfilename, 'InitialPath');
tf = isdir(initialPath);
