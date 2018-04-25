classdef (Sealed)LineAdaptor < matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor
    % A helper class to support Data Cursors on legacy Line objects.
    
    %   Copyright 2010-2014 The MathWorks, Inc.
    
    properties(Access=private, Transient)
        LineDataListener;
    end
    
    methods
        function hObj = LineAdaptor(hLine)
            hObj@matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor(hLine);
        end
    end
    
    methods(Access=protected)
        function doSetAnnotationTarget(hObj, hTarget)
            % Enforce that the target is an image
            if ~ishghandle(hTarget,'line')
                error(message('MATLAB:specgraph:chartMixin:dataannotatable:LineAdaptor:InvalidLine'));
            end
            
            % Add a listener to the image data to fire the DataChanged event
            hObj.LineDataListener = event.proplistener(hTarget, ...
                {hTarget.findprop('XData'), hTarget.findprop('YData'), hTarget.findprop('ZData')}, ...
                'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));
        end
    end
    
    % For the DataAnnotatable interface methods, we will delegate to the
    % LineHelper class.
    methods(Access='protected')
        function descriptors = doGetDataDescriptors(hObj, index, interpolationFactor)
            descriptors = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getDataDescriptors(hObj.AnnotationTarget, index, interpolationFactor);
        end
        
        function index = doGetNearestIndex(hObj, index)
            index = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getNearestIndex(hObj.AnnotationTarget, index);
        end
        
        function index = doGetNearestPoint(hObj, position)
            index = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getNearestPoint(hObj.AnnotationTarget, position);
        end
        
        function [index, interpolationFactor] = doGetInterpolatedPoint(hObj, position)
            [index, interpolationFactor] = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getInterpolatedPoint(hObj.AnnotationTarget, position);
        end
        
        function points = doGetEnclosedPoints(hObj, position)
            points = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getEnclosedPoints(hObj.AnnotationTarget, position);
        end
        
        function [index, interpolationFactor] = doIncrementIndex(hObj, index, direction,int_factor)
            [index, interpolationFactor] = matlab.graphics.chart.interaction.dataannotatable.LineHelper.incrementIndex(hObj.AnnotationTarget, index, direction, int_factor);
        end
        
        function point = doGetDisplayAnchorPoint(hObj, index, interpolationFactor)
            point = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getDisplayAnchorPoint(hObj.AnnotationTarget, index, interpolationFactor);
        end
        
        function point = doGetReportedPosition(hObj, index, interpolationFactor)
            point = matlab.graphics.chart.interaction.dataannotatable.LineHelper.getReportedPosition(hObj.AnnotationTarget, index, interpolationFactor);
        end
    end
end
