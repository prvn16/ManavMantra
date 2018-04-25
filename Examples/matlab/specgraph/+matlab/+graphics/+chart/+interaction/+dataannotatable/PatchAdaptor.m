classdef (Sealed)PatchAdaptor < matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor
    % A helper class to support Data Cursors on legacy Patch objects.
    
    %   Copyright 2010-2014 The MathWorks, Inc.
    
    properties(Access=private, Transient)
        PatchDataListener;
    end
    
    methods
        function hObj = PatchAdaptor(hPatch)
            hObj@matlab.graphics.chart.interaction.dataannotatable.AnnotationAdaptor(hPatch);
        end
    end
    
    methods(Access=protected)
        function doSetAnnotationTarget(hObj, hTarget)
            % Enforce that the target is an image
            if ~ishghandle(hTarget,'patch')
                error(message('MATLAB:specgraph:chartMixin:dataannotatable:PatchAdaptor:InvalidPatch'));
            end
            
            % Add a listener to the image data to fire the DataChanged event
            hObj.PatchDataListener = event.proplistener(hTarget, ...
                {hTarget.findprop('XData'), hTarget.findprop('YData'), hTarget.findprop('ZData')}, ...
                'PostSet',@(obj,evd)(hObj.sendDataChangedEvent));
        end
    end
    
    % For the DataAnnotatable interface methods, we will delegate to the
    % PatchHelper class.
    methods(Access='protected')
        function descriptors = doGetDataDescriptors(hObj, index, interpolationFactor)
            descriptors = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getDataDescriptors(hObj.AnnotationTarget, index, interpolationFactor);
        end
        
        function index = doGetNearestIndex(hObj, index)
            index = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getNearestIndex(hObj.AnnotationTarget, index);
        end
        
        function index = doGetNearestPoint(hObj, position)
            index = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getNearestPoint(hObj.AnnotationTarget, position);
        end
        
        function [index, interpolationFactor] = doGetInterpolatedPoint(hObj, position)
            [index, interpolationFactor] = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getInterpolatedPoint(hObj.AnnotationTarget, position);
        end
        
        function points = doGetEnclosedPoints(~, ~)
            % The adaptor does not yet participate with brushing.
            points = [];
        end
        
        function [index, interpolationFactor] = doIncrementIndex(hObj, index, direction, interpolationStep)
            [index, interpolationFactor] = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.incrementIndex(hObj.AnnotationTarget, index, direction, interpolationStep);
        end
        
        function point = doGetDisplayAnchorPoint(hObj, index, interpolationFactor)
            point = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getDisplayAnchorPoint(hObj.AnnotationTarget, index, interpolationFactor);
        end
        
        function point = doGetReportedPosition(hObj, index, interpolationFactor)
            point = matlab.graphics.chart.interaction.dataannotatable.PatchHelper.getReportedPosition(hObj.AnnotationTarget, index, interpolationFactor);
        end
    end
end
