function ret_ax = cla(varargin)
%CLA Clear current axis.
%   CLA deletes all children of the current axes with visible handles and resets
%   the current axes ColorOrder and LineStyleOrder..
%
%   CLA RESET deletes all objects (including ones with hidden handles)
%   and also resets all axes properties, except Position and Units, to
%   their default values.
%
%   CLA(AX) or CLA(AX,'RESET') clears the single axes with handle AX.
%
%   See also CLF, RESET, HOLD.

%   CLA(..., HSAVE) deletes all children except those specified in
%   HSAVE.

%   Copyright 1984-2016 The MathWorks, Inc. 

% Check for an Axes handle.
% 'isgraphics' will catch numeric graphics handles, but will not catch
% deleted graphics handles, so we need to check for both separately.
if nargin > 0 && (...
        (isscalar(varargin{1}) && ...
        (isgraphics(varargin{1},'axes') || isgraphics(varargin{1},'polaraxes'))) ...
        || isa(varargin{1},'matlab.graphics.axis.AbstractAxes'))
    % If first argument is an axes handle
    ax = varargin{1};
    extra = varargin(2:end);
else
    % Default target is current axes
    ax = gca;
    extra = varargin;
end

% Check to make sure we have a valid scalar axes handle.
% Empty array of axes handles is a no-op.
% Vector of axes or deleted axes is an error.
if isa(ax,'matlab.graphics.chart.Chart')
    error(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'cla', ax.Type));
elseif isscalar(ax) && isgraphics(ax) 
    % Call claNotify to trigger cla related evants.
    claNotify(ax,extra{:});

    % Call clo on the axes
    clo(ax, extra{:});
elseif ~isempty(ax)
    error(message('MATLAB:cla:InvalidAxesHandle'));
end

% Return the axes handle if requested
if (nargout ~= 0)
    ret_ax = ax;
end
