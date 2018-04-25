classdef DataCursorBehaviorHelper < handle & matlab.mixin.SetGet
    % An object to facilitate use of the "graphics.datacursorbehavior"
    % object with the updated "DataAnnotatable" API.
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties
        Position = [0 0 0];
        DataIndex = 1;
        TargetPoint = [0 0 0];
    end
    
    events(NotifyAccess=private)
        % Event that signals that one or more of the object's properties
        % have been altered.  This event can be used to detect changes in
        % the Position and TargetPoint properties during the course of a
        % call to one of the helper methods.
        StateChanged
    end
    
    methods(Access=private) 
        function index = callUpdateFcn(hObj, hAnnotatable, fcn, evtdata)
            %callUpdateFcn Call a Behavior update function and return the index
            
            hObj.TargetPoint = getLocation(hAnnotatable.getReportedPosition(hObj.DataIndex), hAnnotatable.getAnnotationTarget());
            hObj.Position = getLocation(hAnnotatable.getDisplayAnchorPoint(hObj.DataIndex), hAnnotatable.getAnnotationTarget());
              
            eventSender = createPostCallStateChecker(hObj); %#ok<NASGU>

            hgfeval(fcn,hObj,evtdata);
            index = hObj.DataIndex;
        end
        
        function [index, called] = callDataCursorUpdateFcn(hObj, hB, hAnnotatable, targetGenerator)
            %callDataCursorUpdateFcn  Call the DataCursorUpdateFcn if possible
            
            called = hasDataCursorBehaviour(hB, 'UpdateDataCursorFcn');
            index = 1;
            if called
                % Execute the function handle to create a numeric
                % target
                target = targetGenerator();
                
                updateFun = hB.UpdateDataCursorFcn;
                index = callUpdateFcn(hObj, hAnnotatable, updateFun, target);
            end
        end
    end

    
    methods
        function [output, valid] = getDataDescriptorsHelper(hObj, hB, hAnnotatable, index, interpolationFactor)
            
            output = [];
            valid = false;
            
            % For the time being, we need to support the old
            % "datacursorbehavior" object API. In this case, the custom
            % function would always return a string. Consequently, we will
            % create a DataDescriptor object to represent this.
            if hasDataCursorBehaviour(hB, 'UpdateFcn')
                updateFcn = hB.UpdateFcn;
                try
                    % We will reuse the old event object.
                    hEventObj = matlab.graphics.internal.DataTipEvent;
                    hEventObj.Target = hAnnotatable.getAnnotationTarget();
                    hEventObj.Position = getLocation(hAnnotatable.getReportedPosition(index,interpolationFactor), hEventObj.Target);
                    hEventObj.DataIndex = index;
                    hEventObj.InterpolationFactor = interpolationFactor;
                    
                    eventSender = createPostCallStateChecker(hObj); %#ok<NASGU>
                    
                    str = hgfeval(updateFcn,hAnnotatable.getAnnotationTarget(),hEventObj);
                catch E
                    error(message('MATLAB:specgraph:chartMixin:DataAnnotatable:ErrorInCustomFunction'));
                end
                output = matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(str,[]);
                valid = true;
            end

        end
        
        function [index, valid] = nearestPointHelper(hObj, hB, hAnnotatable, pixelPosition)

            % Delegate to the behavior object if it exists. Use the current
            % point in the axes as a target for this.
            [index, valid] = callDataCursorUpdateFcn(hObj, hB, hAnnotatable, @() localConvertToAxesPoint(hAnnotatable.getAnnotationTarget(), pixelPosition));
        end
        
        function [index, interpolationFactor, valid] = interpolatedPointHelper(hObj,hB,hAnnotatable, pixelPosition)
            % Delegate to the behavior object if it exists. Use the current
            % point in the axes as a target for this.
            [index, valid] = callDataCursorUpdateFcn(hObj, hB, hAnnotatable, @() localConvertToAxesPoint(hAnnotatable.getAnnotationTarget(), pixelPosition));
            
            % Interpolation is always 0 for behavior updates
            interpolationFactor = 0;
        end
        
        function [newIndex, interpolationFactor, valid] = incrementHelper(hObj, hB, hAnnotatable, index, direction)
            
            newIndex = 1;
            valid = hasDataCursorBehaviour(hB, 'MoveDataCursorFcn');
            
            if valid
                moveFun = hB.MoveDataCursorFcn;
                hObj.DataIndex = index;
                newIndex = callUpdateFcn(hObj, hAnnotatable, moveFun, direction);
            end
            
            % Interpolation is always 0 for behavior updates
            interpolationFactor = 0;
        end
        
        function [position, valid] = anchorHelper(hObj, hB)
            
            position = [];
            valid = hasDataCursorBehaviour(hB, 'UpdateDataCursorFcn');
            if valid
                % If there is an update function defined we have cached
                % away this information.
                pt = hObj.Position;
                if numel(pt)==2
                    % Make a 2D SimplePoint
                    position = matlab.graphics.shape.internal.util.SimplePoint([pt 0]);
                    position.Is2D = true;
                else
                    position = matlab.graphics.shape.internal.util.SimplePoint(pt);
                end
            end
        end
        
        function [position, valid] = reportedPositionHelper(hObj, hB)
            
            position = [];
            valid = hasDataCursorBehaviour(hB, 'UpdateDataCursorFcn');
            if valid
                % If there is an update function defined we have cached
                % away this information.
                pt = hObj.TargetPoint;
                if numel(pt)==2
                    % Make a 2D SimplePoint
                    position = matlab.graphics.shape.internal.util.SimplePoint([pt 0]);
                    position.Is2D = true;
                else
                    position = matlab.graphics.shape.internal.util.SimplePoint(pt);
                end
            end
        end 
    end
end


function target = localConvertToAxesPoint(hObj, pixelPosition)
    target = specgraphhelper('convertViewerCoordsToDataSpaceCoords', hObj, pixelPosition, true).';
end


function ret = hasDataCursorBehaviour(hB, Fun)
%hasDataCursorBehaviour Check whether a behavior object is valid
%
%   hasDataCursorBehaviour(hBehavior, Func) checks whether hBehavior is
%   valid and has a valid value for the specified function.

ret = false;
if (~isempty(hB) && ishandle(hB)) || (isa(hB, 'matlab.graphics.internal.DataCursorBehavior') && isvalid(hB))
    Fun = hB.(Fun);
    if ~isempty(Fun)
        ret = true;
    end
end
end


function eventSender = createPostCallStateChecker(hObj)
%createPostCallStateChecker Create a cleanup object that sends StateChanged
%
%   createPostCallStateChecker(hObj) creates and returns an onCleanup
%   object that will fire the StateChanged event if any of the properties
%   change between this function being called and the onCleanup being
%   destroyed.

originalState = struct(...
    'Position', hObj.Position, ...
    'DataIndex', hObj.DataIndex, ...
    'TargetPoint', hObj.TargetPoint);
eventSender = onCleanup(@nStateChecker);

    function nStateChecker
        newState = struct(...
            'Position', hObj.Position, ...
            'DataIndex', hObj.DataIndex, ...
            'TargetPoint', hObj.TargetPoint);
        if ~isequal(originalState, newState)
            hObj.notify('StateChanged');
        end
    end
end
