classdef (Sealed) ContourDataCache < handle
    % Class for caching contour data produced by either
    % generatecontourlevel or fillcontourinterval.
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties(Access=?tContourDataCache)
        XData = []
        YData = []
        ZData = []
        
        LowLevels = zeros(1,0)
        HighLevels = zeros(1,0)
        Linked = false(1,0)
        ContourData = cell(1,0)
        
        ZMin = []
        ZMax = []
    end
    
    methods
        function validateCache(cache, x, y, z)
            % Validate the cache with the XData, YData, and ZData.
            
            % Check if the XData, YData, and ZData already match.
            if ~isequaln(x, cache.XData) || ...
                    ~isequaln(y, cache.YData) || ...
                    ~isequaln(z, cache.ZData)
                
                % XData, YData, or ZData have changed.
                cache.XData = x;
                cache.YData = y;
                cache.ZData = z;
                
                % Clear out the cache.
                cache.LowLevels = zeros(1,0);
                cache.HighLevels = zeros(1,0);
                cache.Linked = false(1,0);
                cache.ContourData = cell(1,0);
                cache.ZMin = [];
                cache.ZMax = [];
            end
        end
        
        function data = getContourLineAndFillData(cache, low, high, linkStrips)
            % Get the contour line and fill data related to the specified
            % low and high interval. The line data includes the vertices
            % and strip data for the contour line along the upper (high)
            % edge of the range specified. The fill data includes the
            % vertices and strip data for the contour fill between the
            % lower and upper (high) values. If low is NaN, only the line
            % data is returned. If linkStrips is true, the line segments
            % are linked before they are returned.
            
            % Check the cache for an entry matching the desired high and
            % low interval. If low is NaN, only check high for a match.
            if isnan(low)
                ind = find(cache.HighLevels == high, 1);
            else
                ind = find(cache.HighLevels == high & cache.LowLevels == low, 1);
            end
            
            % Read from the cache if available. Otherwise call either
            % generatecontourlevel or fillcontourinterval.
            alreadyLinked = false;
            if isscalar(ind)
                data = cache.ContourData{ind};
                alreadyLinked = cache.Linked(ind);
            else
                % Get the XData, YData, and ZData
                x = cache.XData;
                y = cache.YData;
                z = cache.ZData;
                
                % Call either generatecontourlevel or fillcontourinterval.
                if isnan(low)
                    % No low specified, call generatecontourlevel.
                    data = matlab.graphics.chart.generatecontourlevel(x,y,z,high);
                else
                    % Low specified, call fillcontourinterval.
                    data = matlab.graphics.chart.fillcontourinterval(x,y,z,low,high);
                end
                
                % Add the data to the cache.
                ind = numel(cache.HighLevels)+1;
                cache.LowLevels(ind) = low;
                cache.HighLevels(ind) = high;
                cache.ContourData{ind} = data;
                cache.Linked(ind) = false;
            end
            
            % Link the line strips if necessary.
            if linkStrips && ~alreadyLinked && ~isempty(data) && ...
                    isfield(data,'LineVertices') && isfield(data, 'LineStripData')
                
                % Link the line strips.
                [data.LineVertices, data.LineStripData] ...
                    = matlab.graphics.chart.internal.contour.linkLineStrips(...
                    data.LineVertices, data.LineStripData);
                
                % Update the cached data.
                cache.ContourData{ind} = data;
                cache.Linked(ind) = true;
            end
        end
        
        function data = getContourFillData(cache, low, high)
            % Get the contour line and fill data related to the specified
            % low and high interval. The line data includes the vertices
            % and strip data for the contour line along the upper (high)
            % edge of the range specified. The fill data includes the
            % vertices and strip data for the contour fill between the
            % lower and upper (high) values. If low is NaN, only the line
            % data is returned.
            
            % Call the internal helper function to get the data.
            data = getContourLineAndFillData(cache, low, high, false);
        end
        
        function contourLines = getContourLines(cache, levels, linkStrips, needFill)
            % Get the contour line data related to the specified list of
            % levels. If linkStrips is true, the line segments are linked
            % before they are returned. If needFill is true, the fill data
            % for the regions between each level are computed along with
            % the contour line data and cached for use later.
            
            % Collect the low and high levels.
            numLevels = numel(levels);
            highLevels = [levels inf];
            if needFill
                % Setting the low values to all NaN indicates not to
                % calculate the fill.
                lowLevels = [NaN levels];
            else
                % Setting the low values to all NaN indicates not to
                % calculate the fill.
                lowLevels = NaN(1,numLevels+1);
            end
            
            % Initialize the ContourLine array.
            if numLevels == 0
                contourLines = matlab.graphics.chart.internal.contour.ContourLine.empty();
            else
                contourLines(numLevels,1) = matlab.graphics.chart.internal.contour.ContourLine;
            end
            
            % Read the contour data.
            for k = 1:numLevels
                low = lowLevels(k);
                high = highLevels(k);
                
                % Call the internal helper function to get the data.
                data = getContourLineAndFillData(cache, low, high, linkStrips);
                
                % Convert the data into a ContourLine object.
                if isempty(data) || ...
                        ~isfield(data,'LineVertices') || ...
                        ~isfield(data, 'LineStripData')
                    contourLines(k).Level = high;
                else
                    contourLines(k) = ...
                        matlab.graphics.chart.internal.contour.ContourLine(...
                        high, data.LineVertices, data.LineStripData);
                end
            end
            
            % Remove empty contour lines.
            contourLines = removeEmpty(contourLines);
        end
        
        function [zmin, zmax] = getZDataRange(cache, z)
            % Calculate the range of the finite data in the ZData.
            
            % Check if the cache is populated, and the ZData matches.
            if isempty(cache.ZMin) || isempty(cache.ZMax) || ...
                    ~isequaln(z, cache.ZData)
                
                % Cache is empty, or the ZData does not match. Calculate
                % the range and store the new values.
                zmin = 0;
                zmax = 0;
                
                if ~isempty(z)
                    finiteIndZ = isfinite(z);
                    if any(finiteIndZ(:))
                        zmax = max(z(finiteIndZ));
                        zmin = min(z(finiteIndZ));
                    end
                end
                
                % Store the values for next time.
                cache.ZData = z;
                cache.ZMin = zmin;
                cache.ZMax = zmax;
            else
                % The ZData matched, use the cached values.
                zmin = cache.ZMin;
                zmax = cache.ZMax;
            end
        end
    end
end
