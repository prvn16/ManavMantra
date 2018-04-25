function savefig(varargin)
%savefig Save figures to a MATLAB figure file
%  
%  savefig(FILENAME) saves the current figure to a file named FILENAME  
%
%  savefig(H, FILENAME) saves the figures identified by the graphics
%  handle array H to a MATLAB figure file called FILENAME.  MATLAB figure
%  files allow you to store entire figures and open them again later or
%  share them with others.  If H is not specified, the current figure is
%  saved.  If FILENAME is not specified, savefig saves to a file called
%  Untitled.fig.  If FILENAME does not include an extension, MATLAB appends
%  .fig.
%
%  savefig(H,FILENAME,'compact') saves the figures identified by the graphics 
%  handle array H to a MATLAB figure file called FILENAME. This MATLAB figure 
%  file can be opened only in R2014b or later version of MATLAB. Using the 
%  'compact' option reduces the size of the MATLAB figure file and the 
%  time required to create the file.
%
%  To save just a part of a figure (for example a specific axes), or to
%  save graphics handles alongside data, use the SAVE command to create a
%  MAT-file.
%
%  Example:
%    peaks;
%    savefig('PeaksFile');
%    close(gcf);
%    ...
%    openfig('PeaksFile');
%
%  See also openfig, open, save, load.

%  Copyright 2011-2017 The MathWorks, Inc.

% Force all graphics update before save  
drawnow;

narginchk(0, 3);

% Split the argument list and get default values if required
% Compact - the FIG file will not be compatible with 
% early version of MATLAB
[h, filename,saveCompactOnly] = localGetHandleAndFile(varargin{:});
matlab.ui.internal.UnsupportedInUifigure(h);

FF = matlab.graphics.internal.figfile.FigFile;
FF.Path = filename;

if ~contains(filename,'.fig')
 error(message('MATLAB:savefig:FigFileExpected'));
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
set(h,'InSaveFig','on');
if saveCompactOnly
    FF.FigFormat =  3 ;
    FF.Format3Data = hgsaveObject(h);
    FF.RequiredMatlabVersion = 80000;
else
    FF.FigFormat =  2;   % for compatibilty
    FF.Format3Data = hgsaveObject(h);
    FF.Format2Data = hgsaveStructClass(h);
    FF.RequiredMatlabVersion = 70000;
end
FF.SaveObjects = true;
% Save data to the file
FF.write();
set(h,'InSaveFig','off');


function [h, filename,saveCompactOnly] = localGetHandleAndFile(varargin)
% Work out whether the user has specified a handle, a filename, or both.

[hInput, fileInput,saveCompactOnly] = matlab.graphics.internal.figfile.processSaveArguments(varargin{:});

% Throw errors for invalid inputs
if ~hInput.Valid || ~localIsFigureArray(hInput.Value)
    E = MException(message('MATLAB:savefig:InvalidHandle'));
    E.throwAsCaller();
end

if ~fileInput.Valid
    E = MException(message('MATLAB:savefig:InvalidFilename'));
    E.throwAsCaller();
end


if ~saveCompactOnly.Valid
   E = MException(message('MATLAB:savefig:InvalidThirdArgument'));
    E.throwAsCaller();
end


h = hInput.Value;
filename = fileInput.Value;
saveCompactOnly = saveCompactOnly.Value;

function ret = localIsFigureArray(hndls)
% Test whether all of the handles in an array are figures
if isempty(hndls)
    % We need to test the class.
    ret = isa(hndls, 'double') || isa(hndls, 'matlab.ui.Figure');
    
else
    ret = all(ishghandle(hndls, 'figure'));
end
