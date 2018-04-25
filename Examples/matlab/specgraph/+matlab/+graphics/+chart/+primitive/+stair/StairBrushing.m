classdef (ConstructOnLoad=true, Sealed) StairBrushing < matlab.graphics.primitive.world.Group
    
    % Class for representing brushing graphics. This object
    % must be parented to the charting object which hosts the brushing.
    % Brushing graphics are painted by the doUpdate method which reuses
    % vertex data calculated in the parent charting object.
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    % Property Definitions:
    
    properties (SetObservable=true, SetAccess='private', GetAccess='public',  Hidden=true )
        BrushStairHandles;
        BrushMarkerHandles;
    end
    
    
    methods
        function hObj = StairBrushing(varargin)
            
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
            if ~isempty(hObj.BrushStairHandles)
                delete(hObj.BrushStairHandles);
                hObj.BrushStairHandles = [];
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
            
            % Calculate vertexToDataIndices, the data index of each vertex.
            % If there are no NaNs in the data this will just be 
            % [1 1 2 2 3 3 ... end end]. If there are NaNs the number of
            % vertices will be less than 2*(data length) and vertexToDataIndices 
            % will skip data indices corresponding to NaNs.
            x = parent.XDataCache;
            y = parent.YDataCache;
            x = x(:);
            y = y(:);
            [nr,nc] = size(y);
            ndx = [1:nr;1:nr];
            yy = y(ndx(1:2*nr-1),:);
            xx = x(ndx(2:2*nr),ones(1,nc));
            vIsNonFinite = ~isfinite(xx) | ~isfinite(yy);
            vertexDataIndices = find(~vIsNonFinite);
                
            brushingGraphicsCreated = false;
            nLayers = size(brushData,1);
            for layer=nLayers:-1:1
 
                
                % Get the brushing array for this row and expand it to identify
                % line segments.
                brushRowData = brushData(layer,:);
                IbrushRowData = false(1,2*length(brushRowData)-1);
                IbrushRowData(1:2:end) = (brushRowData(1:end)>0);
                IbrushRowData(2:2:end) = (brushRowData(1:end-1)>0);
                
                % Remove data indices which correspond to NaNs so that
                % IbrushRowData is indexed on the same basis as the
                % VertexData of the parent Stair.
                IbrushRowData = IbrushRowData(vertexDataIndices);
                
                numBrushedVertices = sum(IbrushRowData);
                if numBrushedVertices==0
                    continue;
                end
                
                % Create primitive brushing objects for each brushing layer
                % If only the last vertex is brushed, line segments cannot be used
                % to identify the brushed data.
                if numBrushedVertices>=2
                    brushStairHandle = matlab.graphics.primitive.world.LineStrip;
                    brushStairHandle.ColorBinding = 'object';
                    hObj.addNode(brushStairHandle);
                else
                    brushStairHandle = [];
                end
                brushMarkerHandle = matlab.graphics.primitive.world.Marker;
                brushMarkerHandle.FaceColorBinding = 'object';
                hObj.addNode(brushMarkerHandle);
                
                % Calculate the StripData for the brushing line. This is
                % done by looping over each vertex of the parent Stair. If 
                % a vertex is brushed and vertexIndexOfBrushedData has skipped
                % an index the right hand end of a gap caused by NaNs has
                % been brushed and we need to start a new strip. If a
                % vertex is brushed and the previous vertex was not brushed
                % we have started a new strip.
                stairVertexData = parent.Edge.VertexData;
                % If the first vertex is brushed, this is the start of the
                % first strip.
                if IbrushRowData(1)
                    brushStripData = uint32(1);
                else
                    brushStripData = [];
                end
                vertexIndexOfBrushedData = cumsum(IbrushRowData);
                for k=2:size(stairVertexData,2)-1
                    if (IbrushRowData(k) && vertexDataIndices(k)-vertexDataIndices(k-1)>=2) || ...
                            (IbrushRowData(k) && ~IbrushRowData(k-1))
                        brushStripData = [brushStripData uint32(vertexIndexOfBrushedData(k))]; %#ok<AGROW>
                    end
                end
                brushStripData = [brushStripData uint32(vertexIndexOfBrushedData(end)+1)]; %#ok<AGROW>

                
                % Identify the color index of any brushed data in this layer. For
                % now this will be the first non-zero entry in the row of the brushData
                % property which corresponds to this brushing layer to conform with
                % R2008a behavior.
                brushColor = matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(brushRowData,...
                    brushStyleMap);
                
                
                % Assign the vertex data to the primitive brushing objects
                if ~isempty(brushStairHandle)
                    brushStairHandle.LineWidth = parent.LineWidth+layer*4;
                    brushStairHandle.VertexData = parent.Edge.VertexData;
                    brushStairHandle.VertexIndices = uint32(find(IbrushRowData));
                    brushStairHandle.StripData =  brushStripData;
                end
                
                stairVertexIndices = find(IbrushRowData);
                brushMarkerHandle.VertexData = parent.MarkerHandle.VertexData;
                brushMarkerHandle.VertexIndices = uint32(floor(stairVertexIndices(2:2:end)/2));
                brushMarkerHandle.Style = parent.MarkerHandle.Style;
                
                
                colorData = matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(brushColor,updateState);
                brushMarkerHandle.FaceColorData = colorData.Data;
                brushMarkerHandle.FaceColorType = colorData.Type;
                if ~isempty(brushStairHandle)
                    brushStairHandle.ColorData = colorData.Data;
                    brushStairHandle.ColorType = colorData.Type;
                end
                
                if ~isempty(brushStairHandle)
                    brushStairHandles(layer) = brushStairHandle;
                else % If brushStairHandle is empty just add a placeholder
                  %  brushStairHandle = matlab.graphics.primitive.world.LineStrip;
                    brushStairHandles(layer) = matlab.graphics.primitive.world.LineStrip;
                end
                brushMarkerHandles(layer) = brushMarkerHandle;
                
                % Add brushing context menus
                brushMarkerHandle.HitTest = 'on';
                addlistener(brushMarkerHandle,'Hit',...
                    @(es,ed) matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));    
                
                if ~isempty(brushStairHandle)
                    brushStairHandle.HitTest = 'on';
                    addlistener(brushStairHandle,'Hit',...
                        @(es,ed) matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));
                end
                
                brushingGraphicsCreated = true;
                
            end
            if brushingGraphicsCreated
               hObj.BrushMarkerHandles = brushMarkerHandles;
               hObj.BrushStairHandles = brushStairHandles;
            end
        end
     
        function brushPrimitiveArray = getBrushPrimitivesForTesting(hObj)        
            brushPrimitiveArray = {hObj.BrushStairHandles,hObj.BrushMarkerHandles};
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
    
    
