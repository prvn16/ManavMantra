classdef brushingUtils
 
    % Copyright 2008-2016 The MathWorks, Inc.
    
    % Class for sharing brushing-related code between matlab.graphics.chart.primitive graphics
    % objects.
    methods (Static)
        % Get the BrushStyleMap from the figure ancestor if it is defined,
        % of the default if not.
        function brushStyleMap = getBrushStyleMap(hObj)           
            f = ancestor(hObj,'figure');
            if ~isempty(f) && ~isempty(f.findprop('BrushStyleMap'))
                brushStyleMap = f.BrushStyleMap;
                if ~(ismatrix(brushStyleMap) && size(brushStyleMap,2)==3 && ...
                        size(brushStyleMap,1)>=1)
                    brushStyleMap = eye(3);
                end
            else
                brushStyleMap = eye(3);
            end
        end
        
        % Perform standard checks on the validity of the BrushData
        % property.
        function isValid = validateBrushing(hObj)
            
            isValid = false;
            % Early return if brushData is empty or not uint8
            % TO DO: Should cast here
            brushData = hObj.BrushData;
            if strcmp(hObj.Visible,'off') || isempty(brushData) || ...
                    all(brushData(:)==0) || ~isnumeric(brushData)
                return;
            end

            % Early return if brushData size does not match ydata size
            if size(brushData,2)~=length(hObj.YData)
                return
            end
            isValid = true;
        end
        
        % Identify the color index of any brushed data in the top layer. For 
        % now this will be the first non-zero entry in the row of the brushData
        % property which corresponds to this brushing layer to conform with 
        % R2008a behavior.
        function brushColor = getBrushingColor(brushRowData,brushStyleMap)            
            I = find(brushRowData>0);
            if ~isempty(I)  
                brushColor = uint8(brushStyleMap(rem(brushRowData(I(1))-1,size(brushStyleMap,1))+1,:)*255);
            else
                brushColor = [];
            end
        end
 
        % Transforms the 3-tuple uint8 brushColor returned from getBrushingColor 
        % to primitive ColorData.
        function colorData = transformBrushColorToTrueColor(brushColor,updateState)
            iter = matlab.graphics.axis.colorspace.IndexColorsIterator;
            iter.Colors = brushColor;
            iter.Indices = 1;
            colorData = updateState.ColorSpace.TransformTrueColorToTrueColor(iter);
        end   
        
        % Callback for a Hit listener on brushing primitives which raises
        % the context menu for brushing actions.
        function addBrushContextMenuCallback(h,eventData)        
        
        % Context menu responds only to right clicks or ctrl-click on the
        % mac
        fig = [];
        if nargin>=2
            if ismac
                fig = ancestor(h,'figure');
                if ~strcmp('alt',fig.SelectionType) && eventData.Button~=3
                    return
                end         
            elseif eventData.Button~=3
                return
            end
        end

        % Establish a figure BrushingContextMenu instance property to store
        % the uicontext menu since primitive graphics have no uicontextmenu
        % property
        if isempty(fig)
            fig = ancestor(h,'figure');
        end
        if ~isprop(fig,'BrushingContextMenu')
            pBrushingContextMenu = fig.addprop('BrushingContextMenu');
            pBrushingContextMenu.Hidden = true;
            pBrushingContextMenu.Transient = true;
        end
    
        % Create the context menu if it has not yet been built.
        if isempty(fig.BrushingContextMenu)
            fig.BrushingContextMenu = uicontextmenu('Parent',fig,...
                'Serializable','off','Tag','BrushSeriesContextMenu',...
                'Visible','on');           
            mreplace = uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:ReplaceWith')),...
                'Tag','BrushSeriesContextMenuReplaceWith');            
            uimenu(mreplace,'Label',getString(message('MATLAB:uistring:brushingutils:NaNs')),'Tag','BrushSeriesContextMenuNaNs',...
                'Callback',{@localReplace NaN});
            uimenu(mreplace,'Label',getString(message('MATLAB:uistring:brushingutils:DefineAConstant')),'Tag',...
                'BrushSeriesContextMenuDefineAConstant','Callback',...
                @localReplace);
            
            uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:Remove')),'Tag',...
                'BrushSeriesContextMenuRemove','Callback',...
                {@localRemove false});
            uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:RemoveUnbrushed')),'Tag',...
                'BrushSeriesContextMenuRemoveUnbrushed','Callback',...
                {@localRemove true});
            uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:CreateVariable')),'Tag',...
                'BrushSeriesContextMenuCreateVariable','Callback',...
                {@datamanager.newvar},'Separator','on');
            uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:PasteDataToCommandLine')),...
                'Tag','BrushSeriesContextMenuPasteDataToCommandLine','Callback',...
                {@datamanager.paste},'Separator','on');
            uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:CopyDataToClipboard')),...
                'Tag','BrushSeriesContextMenuCopyDataToClipboard','Callback',...
                {@datamanager.copySelection});
            uimenu(fig.BrushingContextMenu,'Label',getString(message('MATLAB:uistring:brushingutils:ClearAllBrushing')),...
                'Tag','BrushSeriesContextMenuClearAllBrushing','Callback',...
                @localClearBrushing,'Separator','on');
        end
         
        allOptions = fig.BrushingContextMenu.Children;
        removeOptions = [];
        if isprop(h.Parent,'BarPeers') && (length(h.Parent.BarPeers) > 1)
            %Removing single bars from a Bar series is not currently supported by Bar, all bars in a series must have the same sized XData and YData.
            % toggle visibility of the remove options for a grouped bar
            removeOptions = findall(fig.BrushingContextMenu,...
                'tag','BrushSeriesContextMenuRemove','-or',...
                'tag','BrushSeriesContextMenuRemoveUnbrushed');
        end
        bManager = datamanager.BrushManager.getInstance();
        seltable = bManager.SelectionTable;
        if ~isempty(seltable) && ~any(arrayfun(@(x)any(x.I(:)),seltable))
            % If no data point is selected, hide menu items that assume at
            % least some data is selected
            removeOptions = union(removeOptions,findall(fig.BrushingContextMenu,...
                'tag','BrushSeriesContextMenuCopyDataToClipboard','-or',...
                'tag','BrushSeriesContextMenuPasteDataToCommandLine','-or',...
                'tag','BrushSeriesContextMenuCreateVariable','-or',...
                'tag','BrushSeriesContextMenuRemove','-or',...
                'tag','BrushSeriesContextMenuReplaceWith'));
        end
        
        set(removeOptions,'Visible','off'); 
        set(setdiff(allOptions,removeOptions),'Visible','on');

        % Create a non-serializable Tartget property on the context menu
        % and update it so that callbacks can access an up-to-date version
        % of the object that was clicked.
        if ~isprop(fig.BrushingContextMenu,'Target')
            p = fig.BrushingContextMenu.addprop('Target');
            p.Transient = true;
        end
        fig.BrushingContextMenu.Target = h;
        
       
        % On the pc, context menus are raised on a mouse up event. To make
        % this happen create a listener to the WindowMouseRelease event which
        % displays the context menu. On other platforms, just show the
        % context menu.
        if ispc
            if ~isprop(fig,'BrushingContextMenuListener')
                pBrushingContextMenuListener = fig.addprop('BrushingContextMenuListener');
                pBrushingContextMenuListener.Hidden = true;
                pBrushingContextMenuListener.Transient = true;
            end
            if isempty(fig.BrushingContextMenuListener)
               fcnH = @(es,ed) matlab.graphics.chart.primitive.brushingUtils.showContextMenu(...
                   es,fig.BrushingContextMenu);
               fig.BrushingContextMenuListener = event.listener(fig,'WindowMouseRelease',...
                   fcnH);
            end
        else
            matlab.graphics.chart.primitive.brushingUtils.showContextMenu(fig,fig.BrushingContextMenu);
        end
        
        end

        % Callback for WindowMouseRelease used on the pc to raise the brushing
        % context menu.
        function showContextMenu(fig,pContextMenu)

        % Delete any remaining WindowMouseRelease listener
        if isprop(fig,'BrushingContextMenuListener') && ...
                ~isempty(fig.BrushingContextMenuListener) && ...
                isvalid(fig.BrushingContextMenuListener)
            delete(fig.BrushingContextMenuListener);
            fig.BrushingContextMenuListener = [];
        end

        pContextMenu.Position = get(fig,'CurrentPoint');
        set(pContextMenu,'Visible','on');
        
        end
        
        % Implementation of the brush behavior object DrawFcn
        function histbehaviorDrawFcn(I,colorIndex,gobj)
            if ~isprop(gobj,'BrushPrimitive')
                p = addprop(gobj,'BrushPrimitive');
                p.Transient = true;
            end
            if isempty(gobj.BrushPrimitive)
                gobj.BrushPrimitive = brushing.HistBrushing('Parent',gobj);
            end
            gobj.BrushPrimitive.BrushColorIndex = colorIndex;
            gobj.BrushPrimitive.BrushData = I;

        end
                
    end
end


function localClearBrushing(es,~)

% Clear brushing from clicked axes.
fig =  ancestor(es,'figure');
ax = get(fig,'CurrentAxes');
brushMgr = datamanager.BrushManager.getInstance();
if isprop(handle(fig),'LinkPlot') && get(fig,'LinkPlot')    
    [mfile,fcnname] = datamanager.getWorkspace(1);
    brushMgr.clearLinked(fig,ax,mfile,fcnname);
end
brushing.select.clearBrushing(ax)

end
 
function localReplace(es,~,newValue)

% For Linked Figures pass the var. data reqiured by dataEdit as a property
% of the context menu

if(nargin == 2)
    newValue =[];
end

fig = ancestor(es,'figure');
linkeddata = repmat(struct('VarName','','VarValue',[],'BrushingArray',[]),[0 1]);



if(datamanager.isFigureLinked(fig))
    
% In case of a Linked Plot we have to preevaluate the linked data
% beforehand for dataEdit. dataEdit evaluates the Linked variables data by
% calling evalin(?caller?,?) and its caller is the current (localReplace)
% function which does not contain the required variables. 
% The following logic does the preevaluation.
    
    h = datamanager.LinkplotManager.getInstance();
    sibs = datamanager.getAllBrushedObjects(fig);
    [mfile,fcnname] = datamanager.getWorkspace(1);
    brushMgr = datamanager.BrushManager.getInstance();
   
    for i = 1: length(sibs)
        linkedVars = h.getLinkedVarsFromGraphic(sibs(i),mfile,fcnname,true);
        for j = 1:length(linkedVars)
            varValue = evalin('caller',[linkedVars{j} ';']);
            varStruct = struct('VarName',linkedVars{j},...
                'VarValue',varValue,'BrushingArray',...
                brushMgr.getBrushingProp(linkedVars{j},mfile,fcnname,'I'));
            linkeddata  = [linkeddata;varStruct]; %#ok<AGROW>
        end
    end
end

% Replace brushed data on clicked graphic with optionally specified value
contextMenu = ancestor(es,'uicontextmenu');
if isprop(contextMenu,'Target')
      datamanager.dataEdit([],[],contextMenu.Target,'replace',newValue,linkeddata);
end
end

function localRemove(es,~,state)

% Remove brushed data on clicked graphic
contextMenu = ancestor(es,'uicontextmenu');
fig = ancestor(es,'figure');
linkeddata = repmat(struct('VarName','','VarValue',[],'BrushingArray',[]),[0 1]);

if(datamanager.isFigureLinked(fig))
% In case of a Linked Plot we have to preevaluate the linked data
% beforehand for dataEdit. dataEdit evaluates the Linked variables data by
% calling evalin(?caller?,?) and its caller is the current (localRemove)
% function which does not contain the required variables.
% The following logic does the preevaluation.
    
    
    h = datamanager.LinkplotManager.getInstance();
    sibs = datamanager.getAllBrushedObjects(fig);
    [mfile,fcnname] = datamanager.getWorkspace(1);
    brushMgr = datamanager.BrushManager.getInstance();
    
    for i = 1: length(sibs)
        linkedVars = h.getLinkedVarsFromGraphic(sibs(i),mfile,fcnname,true);
        for j = 1:length(linkedVars)
            varValue = evalin('caller',[linkedVars{j} ';']);
            varStruct = struct('VarName',linkedVars{j},...
                'VarValue',varValue,'BrushingArray',...
                brushMgr.getBrushingProp(linkedVars{j},mfile,fcnname,'I'));
            linkeddata  = [linkeddata;varStruct]; %#ok<AGROW>
        end
    end
end

if isprop(contextMenu,'Target')
    datamanager.dataEdit([],[],contextMenu.Target,'remove',state,linkeddata);
end
end
