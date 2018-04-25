function hgsave(varargin)
% HGSAVE  Saves an HG object hierarchy to a MAT file.
%
% HGSAVE('Filename') saves the current figure to a file named
% 'Filename'.
%
% HGSAVE(H, 'Filename') saves the objects identified by handle array H
% to a file named 'Filename'.  If 'Filename' contains no extension,
% then the extension '.fig' is added.  If H is a vector, none of the
% handles in H may be ancestors or descendants of any other handles in
% H.
%
% HGSAVE(..., '-v6') saves a FIG-file that can be loaded by versions
% prior to MATLAB 7. When creating a figure to be saved and used in a
% version prior to MATLAB 7 use the 'v6' option to the plotting
% commands. See the help for PLOT, BAR and other plotting commands for
% more information.
%
% See also HGLOAD, SAVE.

%   Copyright 1984-2017 The MathWorks, Inc.
%   D. Foti  11/10/97

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% force figure to update before save 
drawnow 

narginchk(1, inf);


% Get the handle to save and the file to save to.
[h, filename, varargin] = localGetHandleAndFile(varargin);

% Process the remaining arguments
[SaveAll, SaveFlag] = localParseOptions(varargin);

FF = matlab.graphics.internal.figfile.FigFile;
FF.Path = filename;
FF.MatVersion = SaveFlag;
FF.FigFormat = 2;
        
if SaveAll
   E = MException(message('MATLAB:hgsave:DeprecatedOption'));
   E.throwAsCaller();   
end

% This code is here to facilitate a warning which is thrown when a visible Figure makes its way into a
% MAT file using the standard save command. Users are warned since loading the MAT file will cause a
% new Figure window to be displayed.
% The warning should not be thrown if the user executes savefig or hgsave (which both call the standard save command).
% In savefig/hgsave, the InSaveFlag will be set to true, however if just a save command is executed, the flag is not
% set.
% The save function will be modified as follows:
%    Get the current warning state
%    Turn off the warning
%    do the save which will call the figure's custom save (see below)
%    if the warning is still on
%        throw the warning
%    Set the warning state back to its original value
%
% Figure's custom save:
% If we land in this method for a visible figure and we are not in savefig/hgsave, turn the warning on
% so when the save is complete, the warning will be thrown.
% Refer to g983667.

hFig = ancestor(h,'figure');
if ~isempty(hFig)
    if numel(hFig) == 1
        hFig.InSaveFig = 'on';
    else
        for i=1:numel(hFig)
            if ~isempty(hFig{i})
                hFig{i}.InSaveFig = 'on';
            end
        end
    end
end
FF.FigFormat = 2;
FF.Format3Data = hgsaveObject(h);
FF.Format2Data = hgsaveStructClass(h) ;
FF.SaveObjects = true;
FF.RequiredMatlabVersion = 70000;

FF.write();

hFig = ancestor(h,'figure');
if ~isempty(hFig)
    if numel(hFig) == 1
        hFig.InSaveFig = 'off';
    else
        for i=1:numel(hFig)
            if ~isempty(hFig{i})
                hFig{i}.InSaveFig = 'off';
            end
        end
    end
end

function [h, filename, args] = localGetHandleAndFile(args)
% Look for a handle and/or filename in input arguments

numargs = length(args);
if ischar(args{1}) || numargs==1
    % Assume just (Filename)
    handle_file = args(1);
    args(1) = [];
else 
    % Assume (h, Filename)
    handle_file = args(1:2);
    args(1:2) = [];
end

[hInput, fileInput] = matlab.graphics.internal.figfile.processSaveArguments(handle_file{:});

% Throw error if there is not a valid, specified filename
if ~fileInput.Specified || ~fileInput.Valid
    E = MException(message('MATLAB:hgsave:InvalidFilename'));
    E.throwAsCaller();
end

% Throw error if there is not a valid handle vector
if  ~hInput.Valid
    E = MException(message('MATLAB:hgsave:InvalidHandle'));
    E.throwAsCaller();
end

h = hInput.Value;
filename = fileInput.Value;



function [SaveAll, SaveFlag] = localParseOptions(args)
% Parse optional flags from remaining arguments

if ~iscellstr(args)
    E = MException(message('MATLAB:hgsave:InvalidOption'));
    E.throwAsCaller();
end

% Default values
SaveAll = false;
SaveFlag = '';
%SaveOldFig = false;

for n = 1:length(args)
    opt = args{n};
    if strcmpi(opt, 'all')
        SaveAll = true;
    elseif ~isempty(regexp(opt, '^-v[\d.]+$', 'once', 'start'))
        % -vX.Y flag is passed on to the save function
        SaveFlag = opt;
    else
        % Error on any unrecognised option
        E = MException(message('MATLAB:hgsave:UnrecognizedOption', opt));
        E.throwAsCaller();
    end
end
