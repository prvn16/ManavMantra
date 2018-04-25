function lims = getAxesLims(obj, axisType)
%This is an undocumented function and may be removed in future.

%   Return the limits for the specified axes. This function is called from
%   java and is intended to return empty if the axes has been deleted.

%   Copyright 2015-2016 The MathWorks, Inc.

import com.mathworks.page.plottool.propertyeditor.AxesLimitInterval;
import com.mathworks.page.plottool.propertyeditor.controls.CategoricalType;
if ishghandle(obj,'axes')
    lims = get(obj,sprintf('%sLim',upper(axisType)));
    % Convert datetime object axes limits to java DateTime
    if ~isnumeric(lims)
        import matlab.graphics.internal.plottools.AxesLimitUtils;
        if isdatetime(lims)
            lims =  [AxesLimitUtils.createJavaDateTime(lims(1)),...
                AxesLimitUtils.createJavaDateTime(lims(2))];
        elseif isduration(lims)
            lims =  [AxesLimitUtils.createJavaDuration(lims(1)),...
                AxesLimitUtils.createJavaDuration(lims(2))];
        elseif iscategorical(lims)
            lims = AxesLimitInterval(CategoricalType(char(lims(1)),categories(lims(1))),...
                CategoricalType(char(lims(2)),categories(lims(2))));
            return
        end
    end
    lims = AxesLimitInterval(lims(1),lims(2));
else
    lims = [];
end