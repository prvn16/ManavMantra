classdef ( ConstructOnLoad=true,Sealed) BarBrushing < matlab.graphics.primitive.world.Group
    
    % Class for representing brushing graphics. This object
    % must be parented to the charting object which hosts the brushing.
    % Brushing graphics are painted by the doUpdate method which reuses
    % vertex data calculated in the parent charting object.
    
    %  Copyright 2010-2013 The MathWorks, Inc.
    
    % Property Definitions:
    
    properties (SetObservable=true, SetAccess='private', GetAccess='public',  Hidden=true )
        BrushFaceHandles;
        BrushEdgeHandles;
    end
    
    
    methods
        function hObj = BarBrushing(varargin)
            
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
                delete(hObj.BrushEdgeHandles);
                hObj.BrushFaceHandles = [];
                hObj.BrushEdgeHandles = [];
            end

            if ~matlab.graphics.chart.primitive.brushingUtils.validateBrushing(parent)
                return;
            end
            brushData = parent.BrushData(parent.BarOrder);
            
            % Find the figure BrushStyleMap, if it has been defined, and make sure
            % it is a nx3 matrix otherwise revert to the default.
            brushStyleMap =  matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(parent);
            
            % Create primitive brushing objects for each brushing layer
            brushFaceHandle = matlab.graphics.primitive.world.Quadrilateral;
            brushFaceHandle.ColorBinding = 'object';
            hObj.addNode(brushFaceHandle);
            brushFaceHandle.HitTest = 'on';
            addlistener(brushFaceHandle,'Hit',@(es,ed)  matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed)); 
            
            % Identify the color index of any brushed data in this layer. For
            % now this will be the first non-zero entry in the row of the brushData
            % property which corresponds to this brushing layer to conform with
            % R2008a behavior.
            brushColor = matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(brushData(1,:),brushStyleMap);

            brushEdgeHandle = [];
            
            % if the edges exist and are visible use their vertex data,
            % otherwise use faces vertex data
            if ~isempty(parent.Edge) && strcmpi(parent.Edge.Visible,'on')
                vertexData = parent.Edge.VertexData;
                brushEdgeHandle = matlab.graphics.primitive.world.LineLoop;
                brushEdgeHandle.ColorBinding = 'object';
                brushEdgeHandle.LineWidth = parent.Edge.LineWidth;
                brushEdgeHandle.LineStyle = parent.Edge.LineStyle;
                brushEdgeHandle.LineJoin = parent.Edge.LineJoin;
                brushEdgeHandle.HitTest = 'on';
                addlistener(brushEdgeHandle,'Hit',@(es,ed)  matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed)); 
                hObj.addNode(brushEdgeHandle);
            else
                vertexData = parent.Face.VertexData;
            end
            
    
            % The Vertex indices for the bar tops are in positions 2 and 3 
            % of each group of 4 vertices constituting each bar.
            % The Vertex indices for the bar bottoms are in positions 1 and
            % 4 of each group of 4 vertices constituting each bar.
            INoBrushVertexIndices = find(brushData(1,:)==0)-1;
            INoBrushVertexIndicesBottomLeft = INoBrushVertexIndices*4+1;
            INoBrushVertexIndicesTopLeft = INoBrushVertexIndices*4+2;
            INoBrushVertexIndicesTopRight = INoBrushVertexIndices*4+3;
            INoBrushVertexIndicesBottomRight = INoBrushVertexIndices*4+4;
            if strcmp('on',parent.Horizontal)
                vertexData(1,INoBrushVertexIndicesTopLeft(:)) = vertexData(1,INoBrushVertexIndicesBottomLeft(:));
                vertexData(1,INoBrushVertexIndicesTopRight(:)) = vertexData(1,INoBrushVertexIndicesBottomRight(:));
            else
                vertexData(2,INoBrushVertexIndicesTopLeft(:)) = vertexData(2,INoBrushVertexIndicesBottomLeft(:));
                vertexData(2,INoBrushVertexIndicesTopRight(:)) = vertexData(2,INoBrushVertexIndicesBottomRight(:));
            end 
            
            brushFaceHandle.VertexData = vertexData;
             
            % Setting the Edge verticies
            if ~isempty(brushEdgeHandle)
                
                % all verticies that are not brushed
                INoBrushVertexIndices = [INoBrushVertexIndicesBottomLeft(:); INoBrushVertexIndicesTopLeft(:); ...
                                         INoBrushVertexIndicesTopRight(:); INoBrushVertexIndicesBottomRight(:)];
                
                %remove vertices that are not brushed
                vertexData(:,INoBrushVertexIndices)= [];       
                                                
                % set the verticies for the edges
                brushEdgeHandle.VertexData = vertexData;
                
                % set one strip for every group of four verticies               
                brushEdgeHandle.StripData = uint32(1:4:length(vertexData)+1);

            end
          
          % Find the brushing color and assign it to the brushing objects
          if ~isempty(brushColor)
              colorData = matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(...
                  brushColor,updateState);
              brushFaceHandle.ColorData = colorData.Data;
              brushFaceHandle.ColorType = colorData.Type;
              % Check to see of this is needed
              brushFaceHandle.Visible = 'on';
              
              if ~isempty(brushEdgeHandle)
                  brushEdgeHandle.ColorData = colorData.Data;
                  brushEdgeHandle.ColorType = colorData.Type;
                  brushEdgeHandle.Visible = 'on';
              end
              
              
          else % If there are no brushed points set the brushing primitives to be invis
              brushFaceHandle.Visible = 'off';
              
              if ~isempty(brushEdgeHandle)
                  brushEdgeHandle.Visible = 'off';
              end
              
          end
          
          hObj.BrushFaceHandles = brushFaceHandle;
          hObj.BrushEdgeHandles = brushEdgeHandle;

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
    
 
