function [directoryname] = uigetdir(varargin)
%UIGETDIR Standard open directory dialog box
%   DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
%   displays a dialog box for the user to browse through the directory
%   structure and select a directory, and returns the directory name
%   as a string.  A successful return occurs if the directory exists.
%
%   The STARTPATH parameter determines the initial folder in which the
%   dialog box opens.
%
%   When the STARTPATH is a valid path, the dialog box opens in the
%   specified folder.
%
%   When the STARTPATH is an empty string ('') or is not a valid path, the
%   dialog box opens in the current folder.
%
%   Parameter TITLE is a string containing a title for the dialog box.
%   When TITLE is empty, a default title is assigned to the dialog box.
%
%   Windows:
%   The TITLE string replaces the default caption inside the
%   dialog box for specifying instructions to the user.
%
%   UNIX:
%   The TITLE string replaces the default title of the dialog box.
%
%   When no input parameters are specified, the dialog box opens in the
%   current directory with the default dialog title.
%
%   The output parameter DIRECTORYNAME is a string containing the
%   directory selected in the dialog box. If the user presses the Cancel
%   button it is set to 0.
%
%   Examples:
%
%   directoryname = uigetdir;
%
%   Windows:
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB');
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');
%
%   UNIX:
%   directoryname = uigetdir('/home/matlab/work');
%   directoryname = uigetdir('/home/matlab/work', 'Pick a Directory');
%
%   See also UIGETFILE, UIPUTFILE.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.

narginchk(0,2)

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% warnfiguredialog will throw a warning in -noFigureWindows mode
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warnfiguredialog('uigetdir')
[directoryname] = uigetdir_helper(varargin{:});
end 
