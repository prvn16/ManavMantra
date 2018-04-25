classdef ( ConstructOnLoad=true, Sealed) StemBrushing < matlab.graphics.primitive.world.Group
    
    % Class for representing brushing graphics. This object
    % must be parented to the charting object which hosts the brushing.
    % Brushing graphics are painted by the doUpdate method which reuses
    % vertex data calculated in the parent charting object.
    
    %  Copyright 2010-2014 The MathWorks, Inc.
    
    % Property Definitions:
    
    properties (SetObservable=true, SetAccess='private', GetAccess='public',  Hidden=true )
        BrushStemHandles;
        BrushMarkerHandles;
    end
    
    
    methods
        function hObj = StemBrushing(varargin)
            
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
            
            % Delete any existing brushing handles
            if ~isempty(hObj.BrushStemHandles)
                delete(hObj.BrushStemHandles);
                hObj.BrushStemHandles = [];
            end
            if ~isempty(hObj.BrushMarkerHandles)
                delete(hObj.BrushMarkerHandles);
                hObj.BrushMarkerHandles = [];
            end
            
            if isempty(hObj.Parent)
                return;
            end
            parent = hObj.Parent;
            
            % Quick return if brushData is invalid
            brushData = parent.BrushData;
            if ~matlab.graphics.chart.primitive.brushingUtils.validateBrushing(parent)
                return;
            end
            
            % Find the figure BrushStyleMap, if it has been defined, and make sure
            % it is a nx3 matrix otherwise revert to the default.
            brushStyleMap =  matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(parent);
            
            brushingGraphicsCreated = false;
            nLayers = size(brushData,1);
            for layer=nLayers:-1:1

                % Create primitive brushing objects for each brushing layer
                brushStemHandle = matlab.graphics.primitive.world.LineStrip;
                brushStemHandle.ColorBinding = 'object';
                hObj.addNode(brushStemHandle);
                brushStemHandle.HitTest = 'on';
                addlistener(brushStemHandle,'Hit',...
                    @(es,ed) matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));
                brushMarkerHandle = matlab.graphics.primitive.world.Marker;
                brushMarkerHandle.FaceColorBinding = 'object';
                hObj.addNode(brushMarkerHandle);
                brushMarkerHandle.HitTest = 'on';
                addlistener(brushMarkerHandle,'Hit',...
                    @(es,ed) matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed)); 

        
                % Identify the color index of any brushed data in this layer. For 
                % now this will be the first non-zero entry in the row of the brushData
                % property which corresponds to this brushing layer to conform with 
                % R2008a behavior.
                brushRowData = brushData(layer,:); 
                brushColor = matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(brushRowData,...
                   brushStyleMap);
 
                % Find the brushing color and assign it to the brushing objects
                if ~isempty(brushColor)
                    colorData = matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(...
                        brushColor,updateState);
                    brushStemHandle.ColorData = colorData.Data;
                    brushStemHandle.ColorType = colorData.Type;
                    brushMarkerHandle.FaceColorData = colorData.Data;
                    brushMarkerHandle.FaceColorType = colorData.Type;
                else % If there are no brushed points, hide the brushing primitives
                    brushMarkerHandle.Visible = 'off';
                    brushStemHandle.Visible = 'off';
                end   
                
                              
                % Reuse the VertexData from the primitive stem and marker
                % graphics and sub-select using the VertexIndices array.
                IbrushRowData = false(1,2*length(brushRowData));
                IbrushRowData(1:2:end) = (brushRowData>0);
                IbrushRowData(2:2:end) = (brushRowData>0);
                brushStemHandle.LineWidth = parent.LineWidth+layer*4;
                stemVertexindices = find(IbrushRowData);           
                if isempty(stemVertexindices)
                    continue;
                end
                
                inValidInd = find(~isfinite(parent.XDataCache) + ~isfinite(parent.YDataCache));
                validInd = setdiff(1:length(brushRowData),inValidInd);
               
                vertexDataInd = 1:length(IbrushRowData);
                
                if ~isempty(inValidInd)
                    % if YData or XData contain NaNs/Inf the size of
                    % parent.Edge.VertexData does not correspond with IbrushRowData,
                    % we have to pad the vertex data with zeros so that
                    % stemVertexindices will point to the right indecies.
                    vertexDataInd = [];
                    for i = 1:length(validInd)
                        vertexDataInd = [vertexDataInd 2*validInd(i)-1 2*validInd(i)]; %#ok<AGROW>
                    end
                end
                   
                vertexData = zeros(3,length(IbrushRowData));
                vertexData(:,vertexDataInd) = parent.Edge.VertexData;
                
                brushStemHandle.VertexIndices = uint32(stemVertexindices);
                brushStemHandle.VertexData = single(vertexData);
                
                markerVertexData = zeros(3,length(IbrushRowData));
                markerVertexData(:,validInd) = parent.MarkerHandle.VertexData;
                
                brushMarkerHandle.VertexData = single(markerVertexData);                              
                
                brushMarkerHandle.VertexIndices = uint32(floor(stemVertexindices(2:2:end)/2));
                brushMarkerHandle.Style = parent.MarkerHandle.Style;
                brushStemHandle.StripData = [];    

                brushStemHandles(layer) = brushStemHandle;
                brushMarkerHandles(layer) = brushMarkerHandle;
                brushingGraphicsCreated = true;
                
            end
            if brushingGraphicsCreated
                hObj.BrushMarkerHandles = brushMarkerHandles;
                hObj.BrushStemHandles = brushStemHandles;
            end
        end
     
        function brushPrimitiveArray = getBrushPrimitivesForTesting(hObj)        
            brushPrimitiveArray = {hObj.BrushStemHandles,hObj.BrushMarkerHandles};
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
    
