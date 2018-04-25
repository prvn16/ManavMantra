function h = loadFigure(fullpath, OverrideVisible)
% This undocumented function may be removed in a future release.

%LOADFIGURE Load a figure from a file.
%
%  H = LOADFIGURE('filename') loads handle graphics figure from the .fig
%  file specified by 'filename,' and returns handles to the new figures.
%
%  H = LOADFIGURE(..., OVERRIDEVISIBLE) overrides the Visible property on
%  the figure stored in the .fig file with the value in OVERRIDEVISIBLE.
%
%  If the fig file was created using hgsave then it may contain graphics
%  objects other than figures.
%
%  See also OPENFIGURE, SAVEFIGURE, LOAD, SAVE.

%  Copyright 2012-2017 The MathWorks, Inc.

narginchk(1,2);

% Put in place a recursion detection that prevents loading this file again.
% This can happen if a CreateFcn causes another loadFigure. Note that the
% unused guard variable here is required since it is keeping an onCleanup
% in scope.
Guard = localCheckRecursion(fullpath);  %#ok<NASGU>  

fc = ?matlab.ui.Figure;
lfc = event.listener(fc, 'InstanceCreated', @(o,e)figureInstanceCreatedForLoad(o,e));

% Load file into an object wrapper.
FF = matlab.graphics.internal.figfile.FigFile(fullpath);

localCheckRequiredVersion(FF);

% Convert to objects
if ~isempty(FF.Format3Data)
    h = FF.Format3Data;
elseif FF.FigFormat==2
    % Load from a structure.  The handles may point to any object type
    h = hgloadStructClass(FF.Format2Data);
elseif FF.FigFormat==3
    % The loaded data is a vector of figure handles
    h = FF.Format3Data;
end

delete(lfc);

% Common post-load actions for classes
localPostClassActions(h, fullpath);

% Nested, so that we can have access to the OverrideProps variable!
function figureInstanceCreatedForLoad(~, evt)
    set(evt.Instance, 'LoadData', OverrideVisible);
end
end    


function Remover = localCheckRecursion(filename)
h = matlab.graphics.internal.figfile.LoadRecursionGuard.getInstance();
try
    Remover = h.addAndRemove(filename);
catch E
    if strcmp(E.identifier, 'MATLAB:graphics:internal:figfile:LoadRecursionGuard:RecursionError')
        % Throw with a new ID
        error('MATLAB:loadFigure:RecursionDetected', '%s', E.message);
    else
        rethrow(E);
    end
end
end


function localCheckRequiredVersion(FF)
% Check the version that saved the file and warn the user if required

if FF.FigFormat==-1
    error(message('MATLAB:loadFigure:InvalidFigFile'));     
elseif FF.RequiredMatlabVersion > 80000  
    warning(message('MATLAB:loadFigure:FileVersion', FF.RequiredMatlabVersionString));
end
end


function localPostClassActions(h, FileName)
% Post-load actions that are common to loading when classes are enabled
%
%  * Set FileName property
%  * Determine an appropriate parent

for n = 1:numel(h)
    if ishghandle(h(n))
        % Look for an appropriate parent
        hP = localGetParent(h(n));
        PMode = get(h(n), 'ParentMode');
        if ~isempty(hP)
            set(h(n), 'Parent', hP, 'ParentMode', PMode);
        end
        
        % Set the filename on figures
        if ishghandle(h(n), 'figure')
            set(h(n), 'FileName', FileName);
        end
    end
end
end

function hP = localGetParent(h)
% Insert a parent entry for objects that have a sensible default parent

hP = [];
if ishghandle(h)
    if isempty(get(h, 'Parent'))
        if isa(h, 'matlab.ui.Figure')
            hP = matlab.ui.Root;
        elseif isa(h, 'matlab.ui.container.Toolbar')
            hP = gcf;
        elseif isa(h, 'ui.UIToolMixin')
            hP = gctb;
        elseif isa(h, 'matlab.ui.container.Tab')
            hP = gctg;    
        elseif isa(h, 'matlab.ui.control.Component') ...
                || isa(h, 'matlab.graphics.mixin.UIParentable') ...
                || isa(h, 'matlab.graphics.mixin.OverlayParentable') 
            hP = gcf;
        elseif isa(h, 'matlab.graphics.mixin.AxesParentable')
            hP = gca;
        end
    end
end
end

function tb = gctb
% Find the first uitoolbar in the current figure, creating one if necessary

tb = findobj(gcf,'Type','uitoolbar');
if ~isempty(tb)
    tb = tb(1);
else
    tb = uitoolbar;
end
end

function tg = gctg
% Find the first uitabgroup in the current figure, creating one if necessary

tg = findobj(gcf,'Type','uitabgroup');
if ~isempty(tg)
    tg = tg(1);
else
    tg = uitabgroup;
end
end
