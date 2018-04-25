function brushRectangle(ax,objs,~,region,lastregion,brushStyleIndex,...
    brushColor,mfile,fcnname)

% Brush all points in brushable graphics contained in the selection
% rectangle defined by the geometry p1,offset

%   Copyright 2007-2015 The MathWorks, Inc.

% This function uses different mechanisms to draw brushing depending on
% whether the corresponding graphics participate in a linked plot. If the
% graphic does not have linked behavior or the plot is not linked, the
% DataAnnotable getEnclosed points is used to identify which data points
% lie inside the brushed region and the BrushData property of brushable
% graphics is set accordingly. If the graphic has linked behavior in
% a linked plot then brushing is handled centrally by the 
% datamanager.brushmanager class. In this case the datamanager.brushmanager
% I property is set and its draw method is used to refresh all centrally
% managed brushing.

% For linked plots the following mechanism is used.
% 1. Obtain the brushing array for each brushed graphic
% 2. Use it to modify the brushing array for each variable, possibly
% creating rows which are not completely brushed in the process.
% 3. Redraw the brushing array for any affected variables. Note that
% all cells in any brushed row to be brushed.

% Get the Linked Figure struct for this axes, if any
brushMgr = datamanager.BrushManager.getInstance();
linkMgr = datamanager.LinkplotManager.getInstance();
linkFigureStruct = [];
linkedVarNames = {};
linkedPlot = false;
fig = ancestor(ax,'figure');
if ~isempty(linkMgr.Figures) 
    ind = [linkMgr.Figures.('Figure')]==handle(fig);
    linkedPlot = any(ind);
    if linkedPlot
        linkFigureStruct = linkMgr.Figures(ind);
    end
end

% Is the brush gesture in extend mode
extendMode = strcmpi(get(fig,'SelectionType'),'extend');

    
for k=1:length(objs)

    objH = objs(k);
    
    if linkedPlot
        gObjLinkInd = find(objH==linkFigureStruct.LinkedGraphics);
    end   
    
    if isprop(objH,'BrushData')
        try % xdata,ydata may be out of sync in an HG error state
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Find the set difference between points enclosed by region
            % and lastregion.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'[
            
            
            
            % If BrushData is out of sync with Y/Zdata,reset the BrushData
            % array           
            bDataMismatch = false;           
            if ishghandle(objH,'surface')
                if ~isequal(size(objH.ZData),size(objH.BrushData))
                    bDataMismatch = true;
                end
            else               
                if ~isequal(size(objH.YData),size(objH.BrushData))
                     bDataMismatch = true;
                end
            end  
            
            if bDataMismatch
                objH.BrushData = [];
            end
            
            
            if length(region)>2 % ROI brushing
                brushImpl = createBrushRegionImpl(objH, region, lastregion);
            elseif length(region)==2 % Vertex only brushing of a single object, find closest
                brushImpl = createBrushVertexImpl(objH, region, lastregion);
            elseif isempty(region)
                brushImpl = createBrushNullImpl();
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Set/clear or toggle brushing array or BrushData values 
            % corresponding to graphic points in the expanded/contracted
            % region.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            isUnlinkedGraphic  = true;
            if linkedPlot && ~isempty(gObjLinkInd)
                % The brushArea is the size of data that the brush indices
                % are for
                if ishghandle(objH,'surface')
                    brushArea = size(get(objH,'ZData'));
                else
                    brushArea = size(get(objH,'YData'));
                end
                
                varNames = localSetBrushArray(brushMgr,linkFigureStruct,gObjLinkInd,...
                                 brushImpl, brushArea, extendMode,brushColor,mfile,fcnname);
                if ~isempty(varNames)
                    linkedVarNames = [linkedVarNames(:);varNames(:)];
                    isUnlinkedGraphic = false;
                end
            end
            
            if isUnlinkedGraphic
                if ishghandle(objH,'surface')
                    Icurrent = (objH.BrushData>0);
                    % BrushData may be empty if points were removed
                    if isempty(Icurrent) 
                        zdata = get(objH,'ZData');
                        Icurrent = false(size(zdata));
                    end
                else
                    Icurrent = (objH.BrushData>0);
                    if size(Icurrent,1)>1
                        Icurrent = any(Icurrent,1);
                    end
                    % BrushData may be empty if points were removed
                    if isempty(Icurrent)
                        ydata = get(objH,'YData');
                        Icurrent = false(size(ydata));
                    end
                end
                
                if extendMode
                    % Undo last operation
                    Icurrent(brushImpl.getLast()) = ~Icurrent(brushImpl.getLast());
                    % Apply this operation
                    Icurrent(brushImpl.getThis()) = ~Icurrent(brushImpl.getThis());
                else
                    % Remove any existing brush and apply this one
                    Icurrent(:) = false;
                    Icurrent(brushImpl.getThis()) = true;
                end              
                brushData = uint8(Icurrent*brushStyleIndex);
                objH.BrushData = brushData;
            end

        catch %#ok<CTCH>
        end
    elseif linkedPlot && ~isempty(hggetbehavior(objH,'linked','-peek')) && ...
            ~isempty(linkFigureStruct.VarNames)       
        % For custom object linked brushing, call the linked behavior
        % object LinkBrushFcn (in datamanager.getVarBrushArrayUsingLinkedBehavior) 
        % to get the variable brushing array corresponding to the brushed region
        % Note that the linked graphic must have evauated without error.
        if ~isempty(gObjLinkInd) && isempty(linkFigureStruct.LinkedGraphics(gObjLinkInd).LinkDataError)
            linkedBehavior = hggetbehavior(objH,'linked','-peek');
            
            % Assign the variable brushing array. The brushmanager draw method
            % below will use the linked behavior object BrushFcn and brush
            % behavior object DrawFcn to actually draw the brushing.        
            for index = 1:3
                varNames = linkFigureStruct.VarNames{gObjLinkInd,index};
                if ~isempty(varNames)
                    subsStr = linkFigureStruct.SubsStr{gObjLinkInd,index};
                    I = datamanager.getVarBrushArrayUsingLinkedBehavior(varNames,...
                        subsStr,linkedBehavior,objH,region,lastregion,...
                        extendMode,mfile,fcnname);
                    brushMgr.setBrushingProp(varNames,mfile,fcnname,'I',I,...
                        'Color',brushColor);
                    linkedVarNames = [linkedVarNames(:);{varNames}];
                end
            end
            
            if ~isempty(linkedBehavior.LinkBrushUpdateObjFcn)
                feval(linkedBehavior.LinkBrushUpdateObjFcn{1},linkedBehavior,...
                    region,lastregion,objH,linkedBehavior.LinkBrushUpdateObjFcn{2:end});
            end
        end
    elseif ~isempty(hggetbehavior(objH,'brush','-peek')) % Unlinked plot custom object brushing
        brushBehavior = hggetbehavior(objH,'brush','-peek');
        % If a BrushFcn is defined for the brush behavior object, call it
        % to obtain a generalized BrushData representation and then draw
        % the brushing graphics by calling the brush behavior object DrawFcn. 
        if isprop(brushBehavior,'BrushFcn') && ~isempty(brushBehavior.BrushFcn)
            newBrushData = feval(brushBehavior.BrushFcn{1},region,objH,...
                  extendMode,brushBehavior.BrushFcn{2:end});
            feval(brushBehavior.DrawFcn{1},newBrushData,bb.DrawFcn{2:end});
        end
    end  
            
end

% Refresh the brush manager if any linked graphics were brushed. This
% should be done after brushing arrays have been updated to minimize 
% the update traffic when brushing multiple graphics from the same variable
if ~isempty(linkedVarNames)
    linkedVarNames = unique(linkedVarNames);
    for k=1:length(linkedVarNames)
        brushMgr.draw(linkedVarNames{k},mfile,fcnname);
    end
end

end


function s = createBrushRegionImpl(objH, thisRegion, lastRegion)
% Brushing implementation that selects inside a rectangle

s.getThis = @nGetThis;
s.getLast = @nGetLast;

encThisDone = false;
encLastDone = false;
encThis = [];
encLast = [];

    function encIndex = nGetThis()
        if ~encThisDone
            encThis = objH.getEnclosedPoints(thisRegion(1:2,:));
            encThisDone = true;
        end
        encIndex = encThis;
    end

    function encIndex = nGetLast()
        if ~encLastDone
            if ~isempty(lastRegion)
                encLast = objH.getEnclosedPoints(lastRegion(1:2,:));
            end
            encLastDone = true;
        end
        encIndex = encLast;
    end
end


function s = createBrushVertexImpl(objH, thisRegion, lastRegion)
% Brushing implementation that selects a single vertex
s.getThis = @nGetThis;
s.getLast = @nGetLast;

encThisDone = false;
encLastDone = false;
encThis = [];
encLast = [];

    function encIndex = nGetThis()
        if ~encThisDone
            hDA = matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(objH);
            if ~isempty(hDA)
                encThis = objH.getNearestPoint(thisRegion);
            end
            encThisDone = true;
        end
        encIndex = encThis;
    end

    function encIndex = nGetLast()
        if ~encLastDone
            hDA = matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(objH);
            if ~isempty(hDA)
                if ~isempty(lastRegion)
                    encLast = objH.getNearestPoint(lastRegion);
                end
            end
            encLastDone = true;
        end
        encIndex = encLast;
   end
end

function s = createBrushNullImpl()
% Null implementation of brushing

s.getThis = @nGetNull;
s.getLast = @nGetNull;

    function encIndex = nGetNull()
        encIndex = [];
    end
end


function ind = convertToVector(ind, sz)
% Compress a vector of indices into an array down into indices into just a
% vector.  This is effectively doing an any(..., 2) across the rows of the
% selection and is used to apply a brushed surface set to a vector YData

if sz(2)>1
    % The rows that are indexed are given by the mod.  This has to be done
    % with zero-indexing and then converted back to one-based indices.  The
    % result from this will have row indices repeated many times but this
    % does not matter in its final usage so we don't bother calling unique.
    ind = mod(ind-1, sz(1))+1; 
end
end


function linkedVarNames = localSetBrushArray(brushMgr,linkFigureStruct,...
                           gObjLinkInd,brushImpl,brushArea,extendMode,...
                           brushColor,mfile,fcnname)
% Use the gObjH BrushData property to sub-assign into the BrushingArray of
% the corresponding data sources. Returns up to 3 references variable names
% in the 3 data sources.

linkedVarNames = [];
if ~isempty(get(linkFigureStruct.LinkedGraphics(gObjLinkInd),'LinkDataError'))
    return
end
linkedVarNames = cell(3,1);
for row=1:3
    varName = linkFigureStruct.VarNames{gObjLinkInd,row};
    
    if ~isempty(varName)
        I = brushMgr.getBrushingProp(varName,mfile,fcnname,'I'); 
        if isempty(I) % Brushed expression
            continue;
        end
        Igraphic = eval(['I' linkFigureStruct.SubsStr{gObjLinkInd,row} ';']);
        linkedVarNames{row} = varName;
              
        % For surfaces with vector valued x or y sources, Iextend/Icontract
        % will be a matrix the same size as the z data source but the brushing
        % array will be a vector the same size as x/y data source. In this case, the 
        % Iextend/Icontract must be converted to a vector the same size as
        % the x/y source using the following rule, which is a consequence of the
        % constraint that only entire rows of matrix valued z data sources may
        % brushed (g659526):
        % 
        % Iextend/Icontract for y data sources (row==2) are logical vectors 
        % the same size as the y data source identifying which rows of z 
        % data are brushed. 
        %
        % Iextend/Icontract for x data sources (row==1) should not modify
        % vector values x data source brushing array. This prevents
        % the situation where brushing a single cell must brush an entire
        % row, which must then brush the entire x data source, which then
        % results in all data being brushed for every brushing gesture.
        if row<=2 && isvector(Igraphic) && ...
                all(brushArea>1)
            if row==2 % YDataSource - 1st dimension of ZData
                indexConverter = @(ind) convertToVector(ind, brushArea);
            else % XDataSource - 2nd dimension of ZData
                continue;  
            end
        else
            indexConverter = @(ind) ind;
        end
        
        if extendMode
            % Undo last operation
            lastInd = indexConverter(brushImpl.getLast());
            Igraphic(lastInd) = ~Igraphic(lastInd);

            % Apply this operation
            thisInd = indexConverter(brushImpl.getThis());
            Igraphic(thisInd) = ~Igraphic(thisInd);
        else
            % Remove any existing brush and apply this one
            Igraphic(:) = false;
            Igraphic(indexConverter(brushImpl.getThis())) = true;
        end  
        
        changeStatus = localSetBrushingArraySubstr(brushMgr,varName,...
            linkFigureStruct.SubsStr{gObjLinkInd,row},Igraphic,mfile,fcnname);
        if changeStatus
             brushMgr.setBrushingProp(varName,mfile,fcnname,'Color',...
                 brushColor);
        end
    end
end
linkedVarNames = linkedVarNames(~cellfun('isempty',linkedVarNames));
end


function changeStatus = localSetBrushingArraySubstr(h,varName,subsstr,I,mfilename,fcnname)

% Subassign the brushing array using the subsstr for the specified variable
changeStatus = false;
ind = find(strcmp(varName,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
       strcmp(fcnname,h.DebugFunctionNames));
if isempty(ind)
    return
end

% I always comes in a row vector (BrushData property). If varName is a 
% column vector we need to transpose. If varName is an array ...
if isempty(subsstr)
    if isequal(size(h.SelectionTable(ind).I),size(I))
        Ilocal = I;
    else
        Ilocal = I';
    end
else
    Ilocal = h.SelectionTable(ind).I;    
    try
        eval(['Ilocal' subsstr ' = I;']);
    catch %#ok<CTCH>
    end
end

Iexist = h.getBrushingProp(ind,mfilename,fcnname,'I');
if ~isequal(Iexist,I)
    h.setBrushingProp(ind,mfilename,fcnname,'I',Ilocal);
    changeStatus = true;
end
end
      
