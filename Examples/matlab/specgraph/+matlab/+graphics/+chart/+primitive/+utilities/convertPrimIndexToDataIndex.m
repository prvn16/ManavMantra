function index = convertPrimIndexToDataIndex(hObj, index, varargin)
% Offset the index based on the number of NaNs that appear in the data

%  Copyright 2012-2013 The MathWorks, Inc.
narginchk(2,3)

if ~isempty(index)  
    if nargin < 3
        propnames = {};
    else
        propnames = varargin{1};
    end
    is3D = any(strcmp(propnames, 'ZData')) && ~isempty(hObj.ZData);
    
    % Gather all the data arrays
    data = cell(1, 2+numel(propnames));
    data{1} = hObj.XData;
    data{2} = hObj.YData;
    for i = 1:length(propnames)
        data{i+2} = hObj.(propnames{i});
    end
    
    % index has come from the primitive, so it corresponds to an index
    % into the non-NaN data indices.  We need to find the non-NaN data
    % values to convert the index into one for the full data array.
    naninfLocs = ~isfinite(data{1});
    firstSize = size(data{1});
    for i = 2:length(data)
        if ~isempty(data{i}) && isequal(size(data{i}), firstSize)
            naninfLocs = naninfLocs | ~isfinite(data{i});
        end
    end
    
    % Check axes scales for x, y, z data
    hAx = ancestor(hObj, 'axes');
    if ~isempty(hAx)
        naninfLocs = matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hAx, 'XScale', 'XLim', hObj.XData, naninfLocs);
        naninfLocs = matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hAx, 'YScale', 'YLim', hObj.YData, naninfLocs);
        if is3D
            naninfLocs = matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hAx, 'ZScale', 'ZLim', hObj.ZData, naninfLocs);
        end
    end
    
    if any(naninfLocs)
        nonNanInfInd = find(~naninfLocs, index(end));
        if length(nonNanInfInd)>=index(end)
            index = nonNanInfInd(index);
        else
            % Something went wrong: we have less data than the
            % primitive index suggests. Return the last data index.
            index = NaN(size(index));
        end
    end
end
