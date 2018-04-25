function updateTicks(hAx,xTickString,yTickString,x)
% Update the axes ticks based on the bars:

%   Copyright 2014-2016 The MathWorks, Inc.

yTickData = get(hAx,yTickString);
if iscategorical(yTickData)
    return;
end
sortedX = sort(x);  
barseriesyTickString = ['barseries' yTickString];
% Set ticks if less than 16 integers and matches previous
if ~isappdata(hAx,barseriesyTickString) || ...
        isequal(yTickData,getappdata(hAx,barseriesyTickString)) || ...
        strcmp(get(hAx,[yTickString 'Mode']),'auto')
    set(hAx,[yTickString 'Mode'],'auto')
    if all(all(floor(sortedX)==sortedX)) && (length(sortedX)<16)
        xDiff = diff(sortedX);
        if all(xDiff > 0)
            vals = double(sortedX); % ticks must be doubles
            tickvals = vals;
            rulerName = ['Active' yTickString(1) 'Ruler'];
            if isprop(hAx, rulerName)
                tickvals = num2ruler(vals, hAx.(rulerName));
            end
            
            % if we have datetime data the labels are usually longer so
            % rotate the labels if there are more than 6
            if isa(tickvals,'datetime') && numel(vals) > 6 && ...
                    yTickString(1) == 'X' && isprop(hAx,'XTickLabelRotation')
                hAx.XTickLabelRotation = 30;
            end
            
            set(hAx,yTickString,tickvals);
        end
        set(hAx,xTickString,'auto')
    end
    setappdata(hAx,barseriesyTickString,get(hAx,yTickString));
end
