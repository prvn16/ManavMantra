classdef ( ConstructOnLoad=true, Sealed) AreaBrushing < matlab.graphics.primitive.world.Group
    
    % Class for representing brushing graphics. This object
    % must be parented to the charting object which hosts the brushing.
    % Brushing graphics are painted by the doUpdate method which reuses
    % vertex data calculated in the parent charting object.
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    % Property Definitions:
    
    properties (SetObservable=true, SetAccess='private', GetAccess='public',  Hidden=true )
        BrushFaceHandles;
    end
    
    
    methods
        function hObj = AreaBrushing(varargin)
            
            % Call the doSetup method:
            hObj.doSetup;
            
            % Pass any P/V pairs to the object:
            if ~isempty(varargin)
                set(hObj,varargin{:});
            end
        end
    end
    
    % Methods Implementation
    methods(Access='private')
        function doSetup(hObj)
            addDependencyConsumed(hObj,'none');
            hObj.Internal = true;
            hObj.Serializable = 'off';
        end
    end
    methods(Access='public')
        function doUpdate(hObj, updateState)
            
            if isempty(hObj.Parent)
                return
            end
            parent = hObj.Parent;
            
            % Delete any existing brushing handles
            if ~isempty(hObj.BrushFaceHandles)
                delete(hObj.BrushFaceHandles);
                hObj.BrushFaceHandles = [];
            end

            if ~matlab.graphics.chart.primitive.brushingUtils.validateBrushing(parent)
                return;
            end
            brushData = parent.BrushData(1,:);

            % Find the figure BrushStyleMap, if it has been defined, and make sure
            % it is a nx3 matrix otherwise revert to the default.
            brushStyleMap =  matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(parent);
        
            % Create primitive brushing objects for each brushing layer
            brushFaceHandle = matlab.graphics.primitive.world.Quadrilateral;
            brushFaceHandle.ColorBinding = 'object';
            hObj.addNode(brushFaceHandle);
            brushFaceHandle.HitTest = 'on';
            addlistener(brushFaceHandle,'Hit',...
                    @(es,ed) matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));            

            % Identify the color index of any brushed data in this layer. For
            % now this will be the first non-zero entry in the row of the brushData
            % property which corresponds to this brushing layer to conform with
            % R2008a behavior.
            brushColor = matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(brushData,brushStyleMap);

            
            % Compute the VertexData and VertexIndices for the
            % Quadrilateral representing the brushing
            [vertices, ~, stripData] = createAreaVertexData(parent, ...
                updateState.DataSpace, updateState.BaseValues(2), find(brushData));
            
            iter = matlab.graphics.axis.dataspace.IndexPointsIterator;
            iter.Vertices=vertices;
            vd = TransformPoints(updateState.DataSpace, ...
                updateState.TransformUnderDataSpace, iter);
            
            brushFaceHandle.VertexData = vd;
            brushFaceHandle.StripData = uint32(stripData);
            brushFaceHandle.VertexIndices = [];
            
            % Find the brushing color and assign it to the brushing objects
            if ~isempty(brushColor)
                colorData = matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(...
                    brushColor,updateState);
                brushFaceHandle.ColorData = colorData.Data;
                brushFaceHandle.ColorType = colorData.Type;
            else % If there are no brushed points set the primitive invisible
                brushFaceHandle.Visible = 'off';
            end
            hObj.BrushFaceHandles = brushFaceHandle;
        end
        
        function brushPrimitiveArray = getBrushPrimitivesForTesting(hObj)
             brushPrimitiveArray = {hObj.BrushFaceHandles};
        end
        
        % Update a graphic object with the fields of a structure generated
        % by createBrushDataStruct (above).
        function remove(~,gobj,keepflag)
            [~,pvPairs] = datamanager.createRemovedProperties(gobj,keepflag);
            set(gobj,pvPairs{:});
        end

    end
    
    
    methods (Static = true)
       
        
        % Create a structure representing the graphic object data which is
        % modified when taking action on brushed data.
        function gStruct = serializeBrushDataStruct(varargin)
            gStruct = datamanager.serializeBrushDataStruct(varargin{:});
        end
        
        % Update a graphic object with the fields of a structure generated
        % by createBrushDataStruct.
        function deserializeBrushDataStruct(brushDataStruct,gObj)
            datamanager.deserializeBrushDataStruct(brushDataStruct,gObj);
        end
    end
    
end
