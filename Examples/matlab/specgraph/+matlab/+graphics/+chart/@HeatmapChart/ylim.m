function yl = ylim(hObj, limits)
%YLIM Set or query y-axis limits
%   YLIM(H, limits) specifies the y-axis limits on the heatmap H. Specify
%   limits as a two-element vector of the form [ymin ymax], where ymin and
%   ymax are elements from the 'YDisplayData' vector in the order present
%   in the 'YDisplayData' vector.
%   
%   yl = YLIM(H) returns a two-element vector containing the y-axis limits
%   for the the heatmap H.
%   
%   YLIM(H, 'auto') resets the y-axis limits on the heatmap H to the full
%   range of the values in the 'YDisplayData' vector.
%   
%   YLIM(H, 'manual') freezes the y-axis limits on the heatmap H at the
%   current values.
%   
%   m = YLIM(H, 'mode') returns the current value of the y-axis limits mode
%   on the heatmap H, which is either 'auto' or 'manual'. By default, the
%   mode is automatic unless you specify limits or set the mode to manual.

%   Copyright 2017 The MathWorks, Inc.

markFigure = false;
if nargin < 2
    % If no additional inputs were provided, return the current value of
    % the YLimits property.
    yl = get(hObj, 'YLimits');
elseif (ischar(limits) || (isstring(limits) && isscalar(limits))) && ...
        ismember(lower(limits), {'auto','manual','mode'})
    if strcmpi(limits,'mode')
        % Query YLimitsMode
        yl = get(hObj, 'YLimitsMode');
    elseif nargout > 0
        % No output arguments are returned when you set the XLimits.
        error(message('MATLAB:nargoutchk:tooManyOutputs'));
    else
        % Set the YLimitsMode to either auto or manual.
        set(hObj, 'YLimitsMode', lower(limits));
        markFigure = true;
    end
elseif nargout > 0
    % No output arguments are returned when you set the YLimits.
    error(message('MATLAB:nargoutchk:tooManyOutputs'));
else
    % Set the YLimits to the specified value.
    set(hObj, 'YLimits', limits);
    markFigure = true;
end

% This command notifies the Live Editor of potential changes to the figure.
if markFigure
    matlab.graphics.internal.markFigure(hObj);
end

end
