classdef(Sealed = true) LineHelper < handle
    % A helper class that provides implementations of DataAnnotatable
    % interface methods for Line subclasses.
    
    %   Copyright 2010-2014 The MathWorks, Inc.
    
    methods(Access = private)
        % We will make the constructor private to prevent instantiation.
        function hObj = LineHelper
        end
    end
    
    methods(Access = public, Static = true)
        
        function [index,int_factor] = incrementIndex(hLine, index, direction,interpolation_factor)
            % get next valid index in the data : skip NaNs and Infs based
            % on the direction of the movement (up,right ,left dowm)
            
            int_factor = interpolation_factor; % we dont change the interpolation factor here, just passing through
            nextIndex = index;

            %use the DataCache properties in order to get the numeric representation of the data.
            xd = hLine.XDataCache;
            yd = hLine.YDataCache;
            zd = hLine.ZDataCache;
            indToAllow = isfinite(xd).* isfinite(yd);
            
            if ~isempty(zd)
                indToAllow = indToAllow.*isfinite(zd);
            end
            
            if strcmpi(direction,'up') || strcmpi(direction,'right')
                nextIndex = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getNearestIndex(hLine,nextIndex + 1);
                if ~indToAllow(nextIndex)
                    nextIndex = nextIndex + find(indToAllow((nextIndex+1):end), 1, 'first');
                end
                
            elseif strcmpi(direction,'down') || strcmpi(direction,'left')
                nextIndex = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getNearestIndex(hLine,nextIndex - 1);
                if ~indToAllow(nextIndex)
                    nextIndex = find(indToAllow(1:nextIndex), 1, 'last');
                end
            end
            
            if ~isempty(nextIndex)
                index = nextIndex;
            end
            
        end
   
           function descriptors = getDataDescriptors(hLine, index, interpolationFactor)
            % Get the data descriptors for a Line given the index and
            % interpolation factor.            
            primpos = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getReportedPosition(hLine,index,interpolationFactor);            
            pos = primpos.getLocation(hLine);           
            descriptors = matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(hLine,pos);               
        end
        
               
        function index = getNearestIndex(hLine, index)
            % Return the nearest index to the requested input.
            
            % If the index is in range, we will return the index.
            % Otherwise, we will error.
            yd = hLine.YDataCache;
            numPoints = numel(yd);
            
            % Constrain index to be in the range [1 numPoints]
            if numPoints>0
                index = max(1, min(index, numPoints));
            end
        end
        
        function index = getNearestPoint(hLine, position)
            % Returns the index representing the point on the Line nearest
            % to a 1x2 pixel position in the figure.
            
            [index1, index2, t] = localGetNearestSegment(hLine, position);
            if t<=0.5
                index = index1;
            else
                index = index2;
            end
            if isempty(index)
                index = 1;
            end
        end
        
        function index = getEnclosedPoints(hLine, polygon)
            
            xd = hLine.XDataCache;
            yd = hLine.YDataCache;
            zd = hLine.ZDataCache;
            data = {xd, yd};
            if ~isempty(zd)
                data{3} = zd;
            end
            
            % Translate polygon into local container reference frame
            polygon = brushing.select.translateToContainer(hLine, polygon);
            
            % Treat data as scattered points and just look for the
            % closest
            utils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            index = utils.enclosedPoints(hLine, polygon, data{:});
        end
        
        function [index, interpolationFactor] = getInterpolatedPoint(hLine, position)
            % Returns the index and interpolation factor representing the
            % point on the Line nearest to a 1x2 pixel position in the
            % figure.
            
            [index, ~, interpolationFactor] = localGetNearestSegment(hLine, position);
        end
        
        function pos = getDisplayAnchorPoint(hLine, index, interpolationFactor)
            % Returns the position that should be used to overlay views on
            % the Line for the given index and interpolation factor.
            
            pos = matlab.graphics.shape.internal.util.LinePoint(...
                localGetPoint(hLine, index), ...
                localGetPoint(hLine, index+1), ...
                interpolationFactor);
        end
        
        function pos = getReportedPosition(hLine, index, interpolationFactor)
            % Returns the position that should be reported back to the user
            % for the given index and interpolation factor.
            
            % The reported position is the same as the anchor position,
            % except the Z value is completely dropped if there is no Z
            % data.
            pos = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getDisplayAnchorPoint(hLine, index, interpolationFactor);
            zd = hLine.ZDataCache;
            if isempty(zd)
                pos.Is2D = true;
            end
        end
    end
    
    
    
    
end


function [index1, index2, t] = localGetNearestSegment(hLine, position)

xd = hLine.XDataCache;
yd = hLine.YDataCache;
zd = hLine.ZDataCache;
data = {xd, yd};
if ~isempty(zd)
    data{3} = zd;
end

% Check that data sizes are consistent
sz = cellfun(@numel, data, 'UniformOutput', true);
if ~all(sz==1 | sz==max(sz))
    index1 = 1;
    index2 = 1;
    t = 0;
    return
end

utils = matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
if strcmpi(hLine.LineStyle,'none')
    % Treat data as scattered points and just look for the
    % closest
    index1 = utils.nearestPoint(hLine, position, true, data{:});
    index2 = index1;
    t = 0;
else
    % Treat data as a sequence of line segments and pick the
    % closest segment
    [index1, index2, t] = utils.nearestSegment(hLine, position, true, data{:});
end

end

function pt = localGetPoint(hLine, index)
% Get the (x,y,z) values of a point on the line

pt = [0 0 0];
xd = hLine.XDataCache;
yd = hLine.YDataCache;
zd = hLine.ZDataCache;
pt(1) = localIndexData(xd, index);
pt(2) = localIndexData(yd, index);
if ~isempty(zd)
    pt(3) = localIndexData(zd, index);
end
end

function val = localIndexData(data, index)
%Index into a vector if the index is valid, return NaN otherwise.

if index>0 && index<=numel(data)
    val = data(index);
else
    val = NaN;
end
end


