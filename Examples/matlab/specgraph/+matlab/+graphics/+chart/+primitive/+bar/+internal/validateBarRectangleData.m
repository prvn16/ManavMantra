function isNonFinite = validateBarRectangleData(hDataSpace, horizontal, xData, xDataLeft, xDataRight, yDataBottom, yDataTop)

import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale;

% Set up values that are dependent upon horizontal vs. vertical bars
if strcmpi(horizontal,'off')
    indep_scale = 'XScale';
    indep_lim = 'XLim';
    dep_scale = 'YScale';
    dep_lim = 'YLim';
else
    dep_scale = 'XScale';
    dep_lim = 'XLim';
    indep_scale = 'YScale';
    indep_lim = 'YLim';   
end

% Remove non-finite XData and YData.
isNonFinite = ~all(isfinite([yDataTop; yDataBottom]),1);
isNonFinite = isNonFinite | ~isfinite(xData);

% Remove any data that is invalid due to the dataspace (i.e. log-scale).
if isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
    % Find x-vertices that are invalid due to the dataspace.
    if ~isempty(xData)
        isNonFinite = isInvalidInLogScale(hDataSpace, indep_scale, indep_lim, xData, isNonFinite);
    end
    
    % Find y-vertices that are invalid due to the dataspace.
    isNonFinite = isInvalidInLogScale(hDataSpace, dep_scale, dep_lim, yDataTop, isNonFinite);
    isNonFinite = isInvalidInLogScale(hDataSpace, dep_scale, dep_lim, yDataBottom, isNonFinite);
    
    isNonFinite = isInvalidInLogScale(hDataSpace, indep_scale, indep_lim, xDataLeft, isNonFinite);
    isNonFinite = isInvalidInLogScale(hDataSpace, indep_scale, indep_lim, xDataRight, isNonFinite);    
end