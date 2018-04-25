classdef (ConstructOnLoad=true,Sealed) ScatterBrushing < matlab.graphics.primitive.world.Group
    
    % Class for representing brushing graphics. This object
    % must be parented to the charting object which hosts the brushing.
    % Brushing graphics are painted by the doUpdate method which reuses
    % vertex data calculated in the parent charting object.
    
    %  Copyright 2010-2015 The MathWorks, Inc.
    
    % Property Definitions:
    
    properties (SetObservable=true, SetAccess='private', GetAccess='public',  Hidden=true )
        BrushStemHandles;
        BrushMarkerHandles;
    end
    
    
    methods
        function hObj = ScatterBrushing(varargin)
            
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
                if ~isempty(hObj.BrushMarkerHandles)
                   delete(hObj.BrushMarkerHandles);
                   hObj.BrushMarkerHandles = [];
                end

                if isempty(hObj.Parent)
                    return;
                end
                parent = hObj.Parent;
            
                if ~matlab.graphics.chart.primitive.brushingUtils.validateBrushing(parent)
                   return;
                end
                brushData = parent.BrushData;
                
                % Find the figure BrushStyleMap, if it has been defined, and make sure
                % it is a nx3 matrix otherwise revert to the default.
                brushStyleMap =  matlab.graphics.chart.primitive.brushingUtils.getBrushStyleMap(parent);
                
                % Identify the color index of any brushed data in this layer. For
                % now this will be the first non-zero entry in the row of the brushData
                % property which corresponds to this brushing layer to conform with
                % R2008a behavior.
                brushColor = matlab.graphics.chart.primitive.brushingUtils.getBrushingColor(brushData(1,:),brushStyleMap);
                
                % Find the brushing color and assign it to the brushing objects
                if ~isempty(brushColor)
                   colorData = matlab.graphics.chart.primitive.brushingUtils.transformBrushColorToTrueColor(...
                         brushColor,updateState);
                else % If there are no brushed points just match the background
                   return;
                end
                
                % Select the SizeData to use.
                s = parent.SizeData;
                if numel(s) > 1
                    s = s(parent.MarkerOrder);
                end
                if all(s == s(1))
                    s = s(1);
                end
                brushData = brushData(:,parent.MarkerOrder);
                vertexData = parent.MarkerHandle.VertexData;
                
                if strcmp(parent.MarkerHandleNaN.Visible,'on')
                    vertexData = [vertexData parent.MarkerHandleNaN.VertexData];
                end
                
                if isempty(brushData)
                    % Nothing to brush
                    return
                end
                
                brushingGraphicsCreated = false;
                for layer=1:size(brushData,1)
                   % First, transform the points:
                   brushRowData = brushData(layer,:);
                   I = find(brushRowData>0);
                   if isempty(I)
                       continue;
                   end
                   % Each row of the vertex data will correspond to a separate marker:
                
                   hM = matlab.graphics.primitive.world.Marker;
                   hM.VertexData = vertexData(:,I);
                   hM.LineWidth = parent.LineWidth;
                   hgfilter('MarkerStyleToPrimMarkerStyle', hM, parent.Marker);
                   if isscalar(s)
                       hM.Size = sqrt(s);
                       hM.SizeBinding = 'object';
                   else
                       hM.Size = sqrt(s(I));
                       hM.SizeBinding = 'discrete';
                   end
                   % Setting either face properties or edge properties of the marker. The logic is hardcoded beause there is no generic way to classify the markers based on their shape. 
                   switch lower(hM.Style)
                       case {'plus','point','asterisk','x'}
                           hM.EdgeColorData = colorData.Data;
                           hM.EdgeColorType = colorData.Type;
                           hM.EdgeColorBinding = 'object';
                       otherwise
                           hM.FaceColorData = colorData.Data;
                           hM.FaceColorType = colorData.Type;
                           hM.FaceColorBinding = 'object';
                   end
                   
                   hObj.addNode(hM);
                   
                   if layer==1
                       markers = hM;
                   else
                       markers(layer) = hM;
                   end
                   hM.HitTest = 'on';
                   addlistener(hM,'Hit',@(es,ed)  matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed)); 
                   brushingGraphicsCreated = true;
                end
                
                % Store the children:
                if brushingGraphicsCreated
                    hObj.BrushMarkerHandles = markers;
                end
        end
     
        function brushPrimitiveArray = getBrushPrimitivesForTesting(hObj)        
            brushPrimitiveArray = {hObj.BrushMarkerHandles};
            
        end
        

        % Update a graphic object with the fields of a structure generated
        % by createBrushDataStruct (above).
        function remove(~,gobj,keepflag)
            [I,pvPairs] = datamanager.createRemovedProperties(gobj,keepflag);
            if length(gobj.SizeData)>1
                pvPairs = [pvPairs {'SizeData',gobj.SizeData(~I)}];
            end
            if size(gobj.CData,1)>1
                pvPairs = [pvPairs {'CData',gobj.CData(~I,:)}];
            end
            set(gobj,pvPairs{:});
        end
    end
    
    methods (Static = true)
        % Create a structure representing the graphic object data which is
        % modified when taking action on brushed data.
        function gStruct = serializeBrushDataStruct(varargin)
            gStruct = datamanager.serializeBrushDataStruct(varargin{:});
            if nargin==0 || isempty(varargin{1})
                fnames = [fieldnames(gStruct); {'Sizedata';'Cdata'}];
                gStruct  = repmat(cell2struct(cell(length(fnames),1),fnames,1),[0 1]);
            else
                gStruct.Sizedata = get(varargin{1},'SizeData');
                gStruct.Cdata = get(varargin{1},'CData');
            end
        end
        
        % Update a graphic object with the fields of a structure generated
        % by createBrushDataStruct.
        function deserializeBrushDataStruct(brushDataStruct,gObj)
            extraPVPairs = {};
            if length(brushDataStruct.Sizedata)>1
                extraPVPairs = [extraPVPairs {'SizeData' brushDataStruct.Sizedata}];
            end
            if size(brushDataStruct.Cdata,1)>1
                extraPVPairs = [extraPVPairs {'CData' brushDataStruct.Cdata}];
            end
            datamanager.deserializeBrushDataStruct(brushDataStruct,gObj,extraPVPairs);
        end
    end    
end
    
    
