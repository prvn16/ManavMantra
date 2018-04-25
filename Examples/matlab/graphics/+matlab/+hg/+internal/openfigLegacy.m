function figOut = openfigLegacy(varargin)
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
%   Copyright 1984-2016 The MathWorks, Inc.

narginchk(0,3);


[~, reusing, visible] = localGetFileAndOptions(varargin);

[path, name, ext] = fileparts(varargin{1});

if isempty(ext)
  ext = '.fig';
elseif ~isequal(lower(ext), '.fig')
    error(message('MATLAB:openfig:FigFileExpected'));
end

filename = fullfile(path, [name ext]);

TOKEN = getToken(filename);
% get the existing list of figures, and prune out stale handles.
figs = getappdata(0, TOKEN);
figs = figs(ishghandle(figs));

% are we reusing an existing figure loaded from the given file?
reusing = reusing && ~isempty(figs);
if ~reusing
    % create another one, unconditionally
    [fig, savedvisible] = hgload(filename, struct('Visible','off'));
    % add listener to remove the appData added for the figures. we could
    % have multiple handles here. 
    figures = handle(fig);
    for i=1:length(figures)
        addlistener(figures(i) ,'ObjectBeingDestroyed', @(o,e) cleanUp(o,e, filename));
    end
    if cellfun('isempty',savedvisible)
        % savedvisible is empty from hgload if the saved value is the
        % same as root's DefaultFigureVisible
        savedvisible = get(0,'DefaultFigureVisible');
    else
        savedvisible = savedvisible{1}.Visible;
        
        % the live editor changes DefaultFigureVisible while running. undo the effect here.
        if ~isdeployed
            editorId = matlab.internal.editor.EODataStore.getRootField('ROOT');
            if ~isempty(editorId) && strcmp(savedvisible,'off')
                savedvisible = 'on';
            end
        end
    end

    figs = [figs(:)' fig(:)'];
    setappdata(figs(end),'SavedVisible',savedvisible);

    % If this is a GUIDE GUI, clear a flag if it is saved in the figure file so
    % that handle structure can be calculated.
    for j = 1:length(fig)
        if isappdata(fig(j),'GUIOnScreen')
            rmappdata(fig(j),'GUIOnScreen');
        end
    end
else
    fig = figs(end);
    savedvisible = getappdata(fig,'SavedVisible');
end

% remember all instances of this figure.
setappdata(0, TOKEN, figs);

% If the figure is not docked, ensure the figure is completely 
% on the screen
for n = 1:length(fig)
    if ~(strcmpi(get(fig(n), 'WindowStyle'), 'docked'))
        movegui(fig(n), 'onscreen');
    end
end

% decide whether to adjust visible
if isempty(visible)
    set(fig,'Visible',savedvisible);
else
    switch visible
        case 'invisible'
            set(fig,'Visible','off');
        case 'visible'
            set(fig,'Visible','on');
        case 'auto'
            if reusing
                set(fig,'Visible',savedvisible);
            else
                set(fig,'Visible','off');
            end
    end
end

% Focus the visible figures
isvis_idx = find(strcmp(get(fig, {'Visible'}), 'on'));
for i=isvis_idx(:)'
    % Focus figures in order; the final figure ends up on top.
    figure(fig(i));
end


if nargout
    figOut = fig;
end

function cleanUp(fig,~,filename)
% remove the appData added for this fig on root
token = getToken(filename);
figs = getappdata(0, token);
if ~isempty(figs)
    figs(figs==fig)=[];
    if isempty(figs)
        rmappdata(0,token);
    else
        setappdata(0,token,figs);
    end    
end

function token = getToken(filename)
% We will use this token, based on the base name of the file
% (without path or extension) to track open instances of figure.
fname = genvarname(filename);         % convert the file name to a valid field name
fname = fliplr(fname);            % file name is more important
token = ['OpenFig_' fname '_SINGLETON']; % hide leading kruft
token = token(1:min(end, namelengthmax));




function [filename, reuse, visibleAction] = localGetFileAndOptions(args)
ip = inputParser;
ip.FunctionName = 'openfig';
ip.addOptional('Filename', 'Untitled.fig', @ischar);
ip.addOptional('Option', '', @ischar);
ip.addOptional('SecondOption', '', @ischar);

ip.parse(args{:});

filename = ip.Results.Filename;

% Find the full path to the file.
filename = matlab.graphics.internal.figfile.findFigFile(filename);

% Check both optional arguments for valid option strings
reuse = false;
visibleAction = '';
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
        reuse = false;
    case {'visible', 'invisible','auto'}
        visibleAction = lower(value);
    otherwise
        error(message('MATLAB:openfig:InvalidOption', value));
end
