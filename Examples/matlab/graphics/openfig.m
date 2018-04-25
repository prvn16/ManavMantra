function figOut = openfig(varargin)
%OPENFIG Open new copy or raise existing copy of saved figure.
%    OPENFIG('NAME.FIG','new') opens figure contained in .fig file,
%    NAME.FIG, and ensures it is completely on screen.  Specifying the
%    .fig extension is optional. Specifying the full path is optional
%    as long as the .fig file is on the MATLAB path.
%
%    If the .fig file contains an invisible figure, OPENFIG returns
%    its handle and leaves it invisible.  The caller should make the
%    figure visible when appropriate.
%
%    OPENFIG('NAME.FIG') is the same as OPENFIG('NAME.FIG','new').
%
%    OPENFIG('NAME.FIG','reuse') opens figure contained in .fig file
%    only if a copy is not currently open, otherwise ensures existing
%    copy is still completely on screen.  If the existing copy is
%    visible, it is also raised above all other windows.
%
%    OPENFIG(...,'invisible') opens as above, forcing figure invisible.
%
%    OPENFIG(...,'visible') opens as above, forcing figure visible.
%
%    F = OPENFIG(...) returns the handle to the figure.
%
%    See also: OPEN, MOVEGUI, GUIDE, GUIHANDLES, SAVE, SAVEAS.

%    OPENFIG(...,'auto') opens as above, forcing figure invisible on
%    creation.  Subsequent calls when the second argument is 'reuse' will
%    obey the visibility setting in the .fig file.
%
%   Copyright 1984-2017 The MathWorks, Inc.
 
% matlab graphic mode
narginchk(0, 3);

% Split the argument list and get default values if required
[filename, reuse, visibleAction] = localGetFileAndOptions(varargin);

% Open a new figure or find an existing one
figOut = localOpenFigure(filename, reuse, visibleAction);

% Apply window visibility rules.
hFigs = figOut(ishghandle(figOut, 'figure'));

% At least one call to drawnow is needed to make 
% sure all figures get a chance to grab focus. 
% movegui already calls drawnow so an addition call
% is not necessary
calldrawnow = true; 
for n = 1:numel(hFigs)
   if ~(strcmpi(get(hFigs(n), 'WindowStyle'), 'docked'))
        movegui(hFigs(n), 'onscreen');
        calldrawnow = false; 
   end
end  

if calldrawnow 
    drawnow 
end 

if isempty(figOut)
    figOut=matlab.ui.Figure.empty;
end


function h = localOpenFigure(filename, reuse, visibleAction)

if ~reuse
    h = loadFigure(filename, visibleAction);
else
    % Search for open figures that have a FileName property that contains
    % this file
    allH = findobj(allchild(0), 'flat', 'FileName', filename);
    if isempty(allH)
        h = loadFigure(filename, visibleAction);
    else
        h = allH(end);
        % set visiblity for reusing the current one.
        if (~isempty(visibleAction))
            set(h, visibleAction);
        end
        % Focus the visible figures
        visidx = find(strcmp(get(h,{'Visible'}), 'on'));
        for i = visidx(:)'
            figure(h(i)); % raise figure to top
        end
    end
end


function [filename, reuse, visibleAction] = localGetFileAndOptions(args)
ip = inputParser;
ip.FunctionName = 'openFigure';
ip.addOptional('Filename', 'Untitled.fig', @ischar);
ip.addOptional('Option', '', @ischar);
ip.addOptional('SecondOption', '', @ischar);
args = matlab.graphics.internal.convertStringToCharArgs(args);
ip.parse(args{:});

filename = ip.Results.Filename;

% Find the full path to the file.
filename = matlab.graphics.internal.figfile.findFigFile(filename);

% Check both optional arguments for valid option strings
reuse = false;
visibleAction = [];
if ~any(strcmp('Option', ip.UsingDefaults))
    [reuse, visibleAction] = localCheckOption(ip.Results.Option, reuse, visibleAction);
end
if ~any(strcmp('SecondOption', ip.UsingDefaults))
    [reuse, visibleAction] = localCheckOption(ip.Results.SecondOption, reuse, visibleAction);
end



function [reuse, visibleAction] = localCheckOption(value, reuse, visibleAction)
switch lower(value)
    case 'reuse'
        reuse = true;
    case 'new'
        reuse = false ;
    case 'visible'
        visibleAction = struct('Visible', 'on');
    case 'invisible'
        visibleAction = struct('Visible', 'off');
    case 'auto'
        visibleAction = [];
    otherwise
        error(message('MATLAB:openfig:InvalidOption', value));
end

