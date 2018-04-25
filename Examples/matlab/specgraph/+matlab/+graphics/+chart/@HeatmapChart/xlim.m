function xl = xlim(hObj, limits)
%XLIM Set or query x-axis limits
%   XLIM(H, limits) specifies the x-axis limits on the heatmap H. Specify
%   limits as a two-element vector of the form [xmin xmax], where xmin and
%   xmax are elements from the 'XDisplayData' vector in the order present
%   in the 'XDisplayData' vector.
%   
%   xl = XLIM(H) returns a two-element vector containing the x-axis limits
%   for the the heatmap H.
%   
%   XLIM(H, 'auto') resets the x-axis limits on the heatmap H to the full
%   range of the values in the 'XDisplayData' vector.
%   
%   XLIM(H, 'manual') freezes the x-axis limits on the heatmap H at the
%   current values.
%   
%   m = XLIM(H, 'mode') returns the current value of the x-axis limits mode
%   on the heatmap H, which is either 'auto' or 'manual'. By default, the
%   mode is automatic unless you specify limits or set the mode to manual.

%   Copyright 2017 The MathWorks, Inc.

markFigure = false;
if nargin < 2
    % If no additional inputs were provided, return the current value of
    % the XLimits property.
    xl = get(hObj, 'XLimits');
elseif (ischar(limits) || (isstring(limits) && isscalar(limits))) && ...
        ismember(lower(limits), {'auto','manual','mode'})
    if strcmpi(limits,'mode')
        % Query XLimitsMode
        xl = get(hObj, 'XLimitsMode');
    elseif nargout > 0
        % No output arguments are returned when you set the XLimits.
        error(message('MATLAB:nargoutchk:tooManyOutputs'));
    else
        % Set the XLimitsMode to either auto or manual.
        set(hObj, 'XLimitsMode', lower(limits));
        markFigure = true;
    end
elseif nargout > 0
    % No output arguments are returned when you set the XLimits.
    error(message('MATLAB:nargoutchk:tooManyOutputs'));
else
    % Set the XLimits to the specified value.
    set(hObj, 'XLimits', limits);
    markFigure = true;
end

% This command notifies the Live Editor of potential changes to the figure.
if markFigure
    matlab.graphics.internal.markFigure(hObj);
end

end
