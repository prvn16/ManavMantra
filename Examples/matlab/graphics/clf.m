function ret_fig = clf(varargin)
%CLF Clear current figure.
%   CLF deletes all children of the current figure with visible handles.
%
%   CLF RESET deletes all children (including ones with hidden
%   handles) and also resets all figure properties, except Position,
%   Units, PaperPosition and PaperUnits, to their default values.
%
%   CLF(FIG) or CLF(FIG,'RESET') clears the single figure with handle FIG.
%
%   FIG_H = CLF(...) returns the handle of the figure.
%
%   See also CLA, RESET, HOLD.

%   CLF(..., HSAVE) deletes all children except those specified in
%   HSAVE.
%
%   Copyright 1984-2016 The MathWorks, Inc.

narginchk(0,3); 

% Check for a Figure handle.
% 'isgraphics' will catch numeric graphics handles, but will not catch
% deleted graphics handles, so we need to check for both separately.
if nargin > 0 && (...
        (isscalar(varargin{1}) && isgraphics(varargin{1},'figure')) ...
        || isa(varargin{1},'matlab.ui.Figure'))
    % If first argument is a figure handle
    fig = varargin{1};
    extra = varargin(2:end);
elseif nargin>0 && isscalar(varargin{1}) && ~isgraphics(varargin{1})
    error(message('MATLAB:clf:InvalidFigureHandle'));
else
    % Default target is current figure
    fig = gcf;
    extra = varargin;
end

% Check to make sure we have a valid scalar figure handle.
if isempty(fig)
    % Empty array of figure handles is a no-op.
    if (nargout ~= 0)
        ret_fig = fig;
    end
    return
elseif ~isscalar(fig) || ~isgraphics(fig)
    % Vector of figures or deleted figures is an error.
    error(message('MATLAB:clf:InvalidFigureHandle'));
end

% Parse the extra input arguments for reset and hsave
reset = [];
hsave = [];
if length(extra) == 2
    reset = extra{1};
    hsave = extra{2};
elseif isscalar(extra)
    if isgraphics(extra{1})
	hsave = extra{1};
    else
        reset = extra{1};
    end
end

matlab.ui.internal.UnsupportedInUifigure(fig);

% Notify the editor that something in the figure is being deleted.
clearingSomething = true;
if ~isempty(hsave)
    hsave = reshape(hsave,[],1);
    ch = fig.Children;
    if length(ch) == length(hsave) && isequal(sort(hsave),sort(ch))
        clearingSomething = false;
    end
end
if clearingSomething
matlab.graphics.internal.clearNotify(fig, 'delete');
end

% annotations are cleared by hand since the handle is hidden
clearscribe(fig);

% If IntegerHandle is 'off', then a numeric handle becomes invalid when
% reset is called on the figure.
fig_was_numeric = isnumeric(fig);
fig_handle = handle(fig);
    
% If the reset option was selected, clear any active modes and any link plot 
% state. 
if ~isempty(reset)
    scribeclearmode(fig_handle);
    if isprop(fig_handle,'ModeManager') && ~isempty(get(fig_handle,'ModeManager'))
        clearModes(get(fig_handle,'ModeManager'));
        set(fig_handle,'ModeManager','');
        uiundo(fig_handle,'clear');
    end
    if ~isdeployed % linkdata is not deployable
        linkDataState = linkdata(fig); 
        if strcmp(get(linkDataState,'Enable'),'on') 
             linkdata(fig,'off'); 
        end 
    end
end

if ~isempty(get(fig,'CurrentAxes'))
    set(fig,'CurrentAxes',[]);
end

% Call clo on the figure
clo(fig, extra{:});

% If IntegerHandle is 'off', then a numeric handle becomes invalid when
% reset is called on the figure, so we need to get the new integer handle.
if fig_was_numeric
    fig = double(fig_handle);
end

% Cause a complete redraw of the figure, so that movie frame remnants
% are cleared as well.
% Calling clo may have caused the figure to be deleted, so make sure the
% figure handle is valid before calling refresh.
if isgraphics(fig)
    refresh(fig)
end

% Now that IntegerHandle can be changed by reset, make sure we're returning
% the new handle:
if (nargout ~= 0)
    ret_fig = fig;
end
