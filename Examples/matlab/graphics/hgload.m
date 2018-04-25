function [h, OldProps] = hgload(filename, varargin)
% HGLOAD  Loads Handle Graphics object from a file.
%
% H = HGLOAD('filename') loads handle graphics objects from the .fig
% file specified by 'filename,' and returns handles to the top-level
% objects. If 'filename' contains no extension, then the extension
% '.fig' is added.
%
% [H, OLD_PROPS] = HGLOAD(..., PROPERTIES) overrides the properties on
% the top-level objects stored in the .fig file with the values in
% PROPERTIES, and returns their previous values.  PROPERTIES must be a
% structure whose field names are property names, containing the
% desired property values.  OLD_PROPS are returned as a cell array the
% same length as H, containing the previous values of the overridden
% properties on each object.  Each cell contains a structure whose
% field names are property names, containing the original value of
% each property for that top-level object. Any property specified in
% PROPERTIES but not present on a top-level object in the file is
% not included in the returned structure of original values.
%
% See also HGSAVE, HANDLE2STRUCT, STRUCT2HANDLE.

%   Copyright 1984-2017 The MathWorks, Inc.
%   D. Foti  11/10/97

if nargin > 0
    filename = convertStringsToChars(filename);
end

% Add a .fig extension if we need to
[filePath,file,fileExt]=fileparts(filename);
if isempty(fileExt) || strcmp(fileExt, '.') % see hgsave.m
  filename = fullfile(filePath, [file , fileExt, '.fig']);
end

% Find the full path to the file.
fullpath = matlab.graphics.internal.figfile.findFigFile(filename);


% Parse the optional input arguments
[LoadAll, OverrideProps] = localParseOptions(varargin);

% Put in place a recursion detection that prevents loading this file again.
% This can happen if a CreateFcn causes another hgload. Note that the
% unused guard variable here is required since it is keeping an onCleanup
% in scope.
Guard = localCheckRecursion(fullpath);  %#ok<NASGU>  

fc = ?matlab.ui.Figure;
lfc = event.listener(fc, 'InstanceCreated', @(o,e)figureInstanceCreatedForLoad(o,e));


% Load file into an object wrapper.
FF = matlab.graphics.internal.figfile.FigFile(filename);

localCheckRequiredVersion(FF);

if LoadAll
    % all option has been removed
    E = MException(message('MATLAB:hgload:DeprecatedOption'));
    E.throwAsCaller();
end

if FF.FigFormat==2
    % Load from a structure
    h = hgloadStructClass(FF.Format2Data);
elseif FF.FigFormat==3
    % The loaded data is a vector of objects
    h = FF.Format3Data;
end

delete(lfc);

% Common post-load actions for classes
OldProps = localPostClassActions(h, fullpath, OverrideProps);

if isempty(h)
    warning(message('MATLAB:hgload:EmptyFigFile'));
    h = matlab.ui.Figure.empty;
end

% Nested, so that we can have access to the OverrideProps variable!
function figureInstanceCreatedForLoad(~, evt)
    set(evt.Instance, 'LoadData', OverrideProps);
end

end    


function [LoadAll, Props] = localParseOptions(args)
% Parse the optional inputs

% Default values
LoadAll = false;
Props = [];

for n = 1:length(args)
    opt = args{n};
    if strcmpi(opt, 'all')
        LoadAll = true;
        
    elseif isstruct(opt)
        % Merge the values into the current set of override property values
        if isempty(Props)
            Props = opt;
        else
            fields = fieldnames(opt);
            for m = 1:numel(fields)
                Props.(fields{m}) = opt.(fields{m});
            end
        end
   
    else
        % Error on any unrecognized option
        if ischar(opt)
            E = MException(message('MATLAB:hgload:UnrecognizedOption', opt));
        else
            E = MException(message('MATLAB:hgload:InvalidOption'));    
        end
        E.throwAsCaller();
    end
end
end


function Remover = localCheckRecursion(filename)
h = matlab.graphics.internal.figfile.LoadRecursionGuard.getInstance();
try
    Remover = h.addAndRemove(filename);
catch E
    if strcmp(E.identifier, 'MATLAB:graphics:internal:figfile:LoadRecursionGuard:RecursionError')
        % Throw with a new ID
        error('MATLAB:hgload:RecursionDetected', '%s', E.message);
    else
        rethrow(E);
    end
end
end


function localCheckRequiredVersion(FF)
% Check the version that saved the file and warn the user if required

if FF.FigFormat==-1
    error(message('MATLAB:hgload:InvalidFigFile'));
    
elseif FF.RequiredMatlabVersion >80000
    
    warning(message('MATLAB:hgload:FileVersion', FF.RequiredMatlabVersionString));
end
end


function OldProps = localPostClassActions(h, FileName, OverrideProps)
% Post-load actions that are common to loading when classes are enabled
%
%  * Set FileName property
%  * Determine an appropriate parent
%  * Set other properties that are specified as override values.

% All of the actions result in extra properties to set.  This cell array of
% structures holds the properties to set for each new object.
Props = cell(size(h));
Props(:) = {[]};
OldProps = Props;

% Add the FileName for figure objects
IsFig = ishghandle(h, 'figure');
Props(IsFig) = {struct('FileName', FileName)};

for n = 1:numel(h)
    %if (ishghandle(h(n),'figure'))
    if (IsFig(n))
        OldProps{n} = get(h(n),'LoadData');
    else
        
        if ~isempty(OverrideProps)
            % Work out which override properties work with each object class.
            [Props{n}, OldProps{n}] = localCheckProperties(h(n), Props{n}, OverrideProps);
        end
        
        % Look for an appropriate parent
        Props{n} = localGetParent(h(n), Props{n});

    end

end

% Set all the new properties on each object.  This loop must be done after
% the previous one to ensure that all properties are found before new
% objects are connected into the existing hierarchy
for n = 1:numel(h)
    if ~isempty(Props{n})        
        set(h(n), Props{n});
    end
end

end


function Props = localGetParent(h, Props)
% Insert a parent entry for objects that have a sensible default parent

hP = [];
if isempty(get(h, 'Parent'))
    if isa(h, 'matlab.ui.Figure')
        hP = handle(0);
    elseif isa(h, 'matlab.ui.container.Toolbar')
        hP = gcf;
    elseif isa(h, 'matlab.ui.container.Tab')
        hP = gctg;
    elseif isa(h, 'ui.UIToolMixin')
        hP = gctb;
    elseif isa(h, 'matlab.ui.control.Component') ...
            || isa(h, 'matlab.graphics.mixin.UIParentable') ...
            || isa(h, 'matlab.graphics.mixin.OverlayParentable') 
        hP = gcf;
    elseif isa(h, 'matlab.graphics.mixin.AxesParentable')
        hP = gca;
    end
end
if ~isempty(hP)
    Props.Parent = hP;
    
    % Re-set parent mode after Parent so that it isn't changed from auto to
    % manual.
    Props.ParentMode = h.ParentMode;
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

function [Props, OldProps] = localCheckProperties(h, Props, OverrideProps)
% Insert override properties that are valid properties for the given
% object.
OldProps = [];
OverrideNames = fieldnames(OverrideProps);
for n = 1:length(OverrideNames)
    if localIsProp(h, OverrideNames{n})
        % Move the override property value into the list for this object
        Props.(OverrideNames{n}) = OverrideProps.(OverrideNames{n});

        if ~isempty(findprop(h, OverrideNames{n})) ...
                && (isempty(findprop(h, [OverrideNames{n} 'Mode'])) ...
                || strcmp(get(h, [OverrideNames{n} 'Mode']), 'manual'))
            
            % Return the current property value if
            %   (a) The property name was exactly specified
            %   (b) Either (i)  there is no Mode property.
            %       Or     (ii) the Mode is set to Manual.
            OldProps.(OverrideNames{n}) = get(h, OverrideNames{n});  
        end
    end
end
end


function ret = localIsProp(h, PropName)
% Check whether a property name is a valid property on an object.  This is
% a replacement for isprop that also allows partial and case-insensitive
% matches to property names

% First do a quick check for an exact match. 
ret = true;
if ~isprop(h, PropName)
    % We have to attempt to access the property in order to determine if it
    % is a partial match
    try
        get(h, PropName);
    catch E %#ok<NASGU>
        ret = false;
    end
end
end


