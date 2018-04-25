function draw(h,varID,mfilename,fcnname)

% Copyright 2008-2015 The MathWorks, Inc.

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.mlwidgets.array.brushing.*;

% Find the variable is the SelectionTable. The fig argument is optional,
% to avoid calling ancestor to find it.

varInSelTable = 1;
if ischar(varID)
    ind = find(strcmp(varID,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
        strcmp(fcnname,h.DebugFunctionNames));
    varName = varID;
    if isempty(ind)
        varInSelTable = 0;
    end
else
    ind = varID;
    varName = h.VariableNames(varID);
end

linkManager = datamanager.LinkplotManager.getInstance();
for k=1:length(linkManager.Figures)
    % Find linked graphics with no LinkDataError
    sublinkedGraphics = any(strcmp(linkManager.Figures(k).VarNames,varName),2);
    for j=1:min(length(sublinkedGraphics),length(linkManager.Figures(k).LinkedGraphics))
        if sublinkedGraphics(j)
            sublinkedGraphics(j) = isempty(get(linkManager.Figures(k).LinkedGraphics(j),...
                'LinkDataError'));
        end
    end
    IlinkedGraphics = find(sublinkedGraphics);
    linkedGraphics = linkManager.Figures(k).LinkedGraphics(IlinkedGraphics);
    if ~isempty(linkedGraphics)
        % If necessary enable brushing on linked graphics. If a graphic 
        % has a linked behavior object but no brushing behavior object it
        % may be unbrushable, so remove it from the list.
        Iunbrushable = [];
        for j=1:length(linkedGraphics)
            if ~isprop(linkedGraphics(j),'BrushData') && ...
                    isempty(hggetbehavior(linkedGraphics(j),'brush','-peek'))
                Iunbrushable = [Iunbrushable;j]; %#ok<AGROW>
            end
        end
        if ~isempty(Iunbrushable)
            linkedGraphics(Iunbrushable) = [];
            IlinkedGraphics(Iunbrushable) = [];
        end
        
        % Generate BrushData properties for linked graphics from the variable
        % brushing arrays and the sub-index string stored in the
        % linkplotmanager. Variables other than varName may be involved in
        % the because graphic objects can have multiple data sources
        % referencing multiple workspace variables.
        for j=1:length(IlinkedGraphics)
            otherVarNames = linkManager.Figures(k).VarNames(IlinkedGraphics(j),:);
            otherSubStrs = linkManager.Figures(k).SubsStr(IlinkedGraphics(j),:);

            if isprop(linkedGraphics(j),'BrushData')
                newBrushData = localCreateBrushArray(h,...
                    linkedGraphics(j),varName,ind,otherVarNames,otherSubStrs,...
                    mfilename,fcnname,linkManager.Figures(k).Figure);

                if ~isequal(newBrushData,get(linkedGraphics(j),'BrushData'))
                    linkedGraphics(j).BrushData = uint8(newBrushData);
                end
            elseif ~isempty(hggetbehavior(linkedGraphics(j),'brush','-peek'))
                bb = hggetbehavior(linkedGraphics(j),'brush');
                newBrushData = localCustomCreateBrushArray(h,linkedGraphics(j),...
                     ind,otherSubStrs,linkManager.Figures(k).Figure);
                feval(bb.DrawFcn{1},newBrushData,linkedGraphics(j),bb.DrawFcn{2:end});
            end
        end
    end
end


if varInSelTable
    % If this variable is represented in the Variable Editor, update the brushing
    aeind = find(strcmp(h.ArrayEditorVariables,varName));
    for k=1:length(aeind)
        varStr = [h.ArrayEditorVariables{aeind(k)} h.ArrayEditorSubStrings{aeind(k)}];
        ArrayEditorManager.setSelection(varStr);
        BrushingActionFactory.setVarBrushedState(varName,any(h.SelectionTable(ind).I(:)));
    end
end

function I = localCreateBrushArray(h,gObj,thisVar,thisVarInd,varNames,...
    subStrs,mfilename,fcnname,fig)

% Computes the 1,2 or 3 by n BrushData array for gObj based on the 3-tuples
% varNames,subStrs corresponding to the 3 data source variable names and
% sub-index strings. The brushmanager indexposition thisVarInd for thisVar
% is passed in for speed. The returned array has data type uint8.

if isempty(fig.findprop('BrushStyleMap'))
    addprop(fig,'BrushStyleMap');
end
brushStyleMap = get(fig,'BrushStyleMap');
if isnumeric(gObj)
    gObj = handle(gObj);
end
Icell = cell(3,1);
for k=1:3 % Loop over the 3 data sources
    I = [];
    % Get the brush array and brush color for the variable referenced
    % by this data source
    if ~isempty(thisVarInd) && strcmp(varNames{k},thisVar) 
        I = h.SelectionTable(thisVarInd).I;
        if ~isvector(I)
            I = I(:,:);
            I = repmat(any(I,2),[1 size(I,2)]);
        end
        brushColor = h.SelectionTable(thisVarInd).Color;   
    elseif ~isempty(varNames{k}) && ~strcmp(varNames{k},thisVar)
         ind = find(strcmp(varNames{k},h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
           strcmp(fcnname,h.DebugFunctionNames));
         if ~isempty(ind)
             I = h.SelectionTable(ind).I;
             if ~isvector(I)
                 I = I(:,:);
                 I = repmat(any(I,2),[1 size(I,2)]);
             end
             brushColor = h.SelectionTable(ind).Color;  
         end
    end

    % Restrict the brushing array using the subref in the data source
    if ~isempty(I)
        try
            brushDataCandidate = eval(['I' subStrs{k} ';']);
            if isvector(brushDataCandidate)
                brushDataCandidate = brushDataCandidate(:)';
            end
        catch %#ok<CTCH>
            brushDataCandidate = [];
        end

        % Get the color index from the figure BrushStyleMap - creating a
        % new row if the color is not represented
        if ~isempty(brushDataCandidate)
            brushIndex = [];
            for brow = 1:size(brushStyleMap,1)
                if isequal(brushColor,brushStyleMap(brow,:))
                    brushIndex = brow;
                    break;
                end
            end
            
            % If this color is not in the FigureStyleMap then add a new
            % entry to represent it
            if isempty(brushIndex)
                brushStyleMap = [brushStyleMap; brushColor]; %#ok<AGROW>
                brushIndex = size(brushStyleMap,1);
                set(fig,'BrushStyleMap',brushStyleMap)
            end           
            Icell{k} = uint8(brushDataCandidate)*uint8(brushIndex);   
        end
    end
end


% For surface plots we cannot have stacked brushing arrays and we may need
% to expand vector-valued x and y sources to the full array size
if ishghandle(gObj,'Surface')
    I = false(size(gObj.ZData));
    Ix = Icell{1};
    brushStyleMapValues = [0 0 0];
    
    if ~isempty(Ix) % XDataSource - msut ignore if XDataSource is vector
        brushStyleMapValues(1) = max(Ix(:));
        % If XDataSource is a vector we cannot expand the selected vector
        % elements to the ZDataSouce matrix because of the constraint that
        % entire rows of the ZDataSource must be brushed and the
        % XDataSource represents the columns when it is a vector.
        % Essentially the constraint that entire rows must be brushed would
        % require brushing a single column to brush all entries in the
        % ZDataSource matrix.
        if ~isvector(Ix)
            I = I | (Ix>0);
        end
    end
    Iy = Icell{2};
    
    if ~isempty(Iy) % YDataSource - may need to expand row->full array
        brushStyleMapValues(2) = max(Iy(:));
        if isvector(Iy)
            Icol = (Iy>0);
            Icol = Icol(:);
            I = I | repmat(Icol,[1 size(I,2)]);
        else
            I = I | (Iy>0);
        end
    end
    Iz = Icell{3};    
    if ~isempty(Iz)
        brushStyleMapValues(3) = max(Iz(:));
        I = I | (Iz>0);
    end
    nonZeroBrushStyleMapValues = brushStyleMapValues(brushStyleMapValues>0);
    if ~isempty(nonZeroBrushStyleMapValues) && max(nonZeroBrushStyleMapValues)==min(nonZeroBrushStyleMapValues)
        I = uint8(I)*max(nonZeroBrushStyleMapValues);
    else % Default to the first BrushStyleMap
        I = uint8(I);
    end
% Area and bar series currently do not allow stacked brushing
elseif isa(gObj,'Bar') || isa(gObj,'Area')
    ind = find(~cellfun('isempty',Icell));
    if ~isempty(ind)
        I = Icell{ind(1)};
        setDefaultColor = false;
        for k=2:length(ind)      
            % If brushing colors are different revert color to first entry
            % in figure BrushStyleMap
            thisI = Icell{ind(k)};
            if ~setDefaultColor && max(thisI(:))~=max(I(:)) && max(thisI(:))>0
                setDefaultColor = true;
            end
            I = uint8(I).*uint8(Icell{ind(k)}>0);
        end
        if setDefaultColor
            I(I>0) = uint8(1);
        end
    else
        I = zeros(size(get(gObj,'XData'),1),size(get(gObj,'XData'),2),'uint8');
    end
else
    ind = find(~cellfun('isempty',Icell));
    if ~isempty(ind)
        % In case the brushing arrays have mismatching sizes, the
        % concatenation may fail. In this case just bail and return []
        try
            I = Icell{ind(1)};
            for k=2:length(ind)
                I = [I;Icell{ind(k)}]; %#ok<AGROW>
            end
        catch %#ok<CTCH>
            I = zeros(size(get(gObj,'XData'),1),size(get(gObj,'XData'),2),'uint8');
        end
    else
        I = zeros(size(get(gObj,'XData'),1),size(get(gObj,'XData'),2),'uint8');
    end
end

function brushDataCandidate = localCustomCreateBrushArray(h,gObj,thisVarInd,subStrs,fig)

% Computes the 1,2 or 3 by n BrushData array for gObj based on the 3-tuples
% varNames,subStrs corresponding to the 3 data source variable names and
% sub-index strings. The brushmanager indexposition thisVarInd for thisVar
% is passed in for speed.

if isempty(fig.findprop('BrushStyleMap'))
    addprop(fig,'BrushStyleMap');
end

brushStyleMap = get(fig,'BrushStyleMap');
brushDataCandidate = [];    


if isempty(thisVarInd)
    bh = hggetbehavior(gObj,'linked');
    if ~isempty(bh)
        brushDataCandidate = feval(bh.BrushFcn{1},[],gObj,bh.BrushFcn{2:end});
    end   
    return
end
 
% Get the brush array and brush color for the variable referenced
% by this data source
I = h.SelectionTable(thisVarInd).I;
if ~isvector(I)
    I = I(:,:);
    I = repmat(any(I,2),[1 size(I,2)]);
end

brushColor = h.SelectionTable(thisVarInd).Color;   

% Restrict the brushing array using the subref in the data source
if ~isempty(I)
    brushDataCandidate = eval(['I' subStrs{2} ';']);
    if isvector(brushDataCandidate)
        brushDataCandidate = brushDataCandidate(:)';
    end

    brushIndex = [];
    for brow = 1:size(brushStyleMap,1)
        if isequal(brushColor,brushStyleMap(brow,:))
            brushIndex = brow;
            break;
        end
    end

    % If this color is not in the FigureStyleMap then add a new
    % entry to represent it
    if isempty(brushIndex)
        brushStyleMap = [brushStyleMap; brushColor];
        brushIndex = size(brushStyleMap,1);
        set(fig,'BrushStyleMap',brushStyleMap)
    end    

    bh = hggetbehavior(gObj,'linked');
    if ~isempty(bh)
       brushDataCandidate = feval(bh.BrushFcn{1},brushDataCandidate*brushIndex,gObj,bh.BrushFcn{2:end});
    end

end
