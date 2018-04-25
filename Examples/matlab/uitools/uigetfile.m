function [filename, pathname, filterindex] = uigetfile(varargin)

%UIGETFILE Standard open file dialog box.
%   [FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE)
%   displays a dialog box for the user to fill in, and returns the filename
%   and path strings and the index of the selected filter. A successful
%   return occurs only if the file exists.  If the user  selects a file
%   that does not exist, an error message is displayed,  and control
%   returns to the dialog box. The user may then enter  another filename,
%   or press the Cancel button.
%
%   The FILTERSPEC parameter determines the initial display of files in
%   the dialog box.  For example '*.m' lists all MATLAB code files.  If
%   FILTERSPEC is a cell array, the first column is used as the list of
%   extensions, and the second column is used as the list of descriptions.
%
%   When FILTERSPEC is a string or a cell array, "All files" is appended
%   to the list.
%
%   When FILTERSPEC is empty the default list of file types is used.
%
%   Parameter TITLE is a string containing the title of the dialog box.
%
%   The output variable FILENAME is a string containing the name of the
%   file selected in the dialog box.  If the user presses Cancel, it is set
%   to 0.
%
%   The output variable PATHNAME is a string containing the path of the
%   file selected in the dialog box.  If the user presses Cancel, it is set
%   to 0.
%
%   The output variable FILTERINDEX returns the index of the filter
%   selected in the dialog box. The indexing starts at 1. If the user
%   presses Cancel, it is set to 0.
%
%   [FILENAME, PATHNAME, FILTERINDEX] = UIGETFILE(FILTERSPEC, TITLE, FILE)
%   FILE is a string containing the name to use as the default selection.
%
%   [FILENAME, PATHNAME] = UIGETFILE(..., 'MultiSelect', SELECTMODE)
%   specifies if multiple file selection is enabled for the UIGETFILE
%   dialog. Valid values for SELECTMODE are 'on' and 'off'. If the value of
%   'MultiSelect' is set to 'on', the dialog box supports multiple file
%   selection. 'MultiSelect' is set to 'off' by default.
%
%   The output variable FILENAME is a cell array of strings if multiple
%   filenames are selected. Otherwise, it is a string representing
%   the selected filename.
%
%   [FILENAME, PATHNAME] = UIGETFILE(..., 'Location', [X Y]) places the
%   dialog box at screen position [X,Y] in pixel units. This option is
%   supported on UNIX platforms only.  
%   NOTE: THIS SYNTAX IS OBSOLETE AND WILL BE IGNORED
%
%   [FILENAME, PATHNAME] = UIGETFILE(..., X, Y) places the dialog box at
%   screen position [X,Y] in pixel units. This option is supported on UNIX
%   platforms only.  
%   NOTE: THIS SYNTAX IS OBSOLETE AND WILL BE IGNORED. 
%
%   Examples:
%
%   [filename, pathname, filterindex] = uigetfile('*.m', 'Pick a MATLAB code file');
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
%       '*.m',  'MATLAB Code (*.m)'; ...
%       '*.fig','Figures (*.fig)'; ...
%       '*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file');
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file', 'Untitled.mat');
%
%   Note, multiple extensions with no descriptions must be separated by semi-
%   colons.
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m';'*.mdl';'*.mat';'*.*'}, ...
%       'Pick a file');
%
%   Associating multiple extensions with one description:
%
%   [filename, pathname] = uigetfile( ...
%      {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%       '*.*',                   'All Files (*.*)'}, ...
%       'Pick a file');
%
%   Enabling multiple file selection in the dialog:
%
%   [filename, pathname, filterindex] = uigetfile( ...
%      {'*.mat','MAT-files (*.mat)'; ...
%       '*.mdl','Models (*.mdl)'; ...
%       '*.*',  'All Files (*.*)'}, ...
%       'Pick a file', ...
%       'MultiSelect', 'on');
%
%   This code checks if the user pressed cancel on the dialog.
%
%   [filename, pathname] = uigetfile('*.m', 'Pick a MATLAB code file');
%   if isequal(filename,0) || isequal(pathname,0)
%      disp('User pressed cancel')
%   else
%      disp(['User selected ', fullfile(pathname, filename)])
%   end
%
%
%   See also UIGETDIR, UIPUTFILE.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.

narginchk(0,7)

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% warnfiguredialog will throw a warning in -noFigureWindows mode
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warnfiguredialog('uigetfile')
[filename, pathname, filterindex] = uigetputfile_helper(0, varargin{:});
end 
