function drag(es,ed,this) %#ok<INUSL>

fig = ancestor(es,'figure');
if ~strcmp(get(fig,'SelectionType'),'normal')
    return
end

if datamanager.isFigureLinked(fig)
    import com.mathworks.page.datamgr.brushing.*;
    
    % Identify a single brushed variable
    linkMgr = datamanager.LinkplotManager.getInstance();
    [mfile,fcnname] = datamanager.getWorkspace(1);
    linkedVarList = linkMgr.getLinkedVarsFromGraphic(this.HGHandle,mfile,fcnname); 
    if isempty(linkedVarList) % Dragging an unlinked graphic
        this.drag;
        return
    elseif length(linkedVarList)>=2
         errordlg(sprintf('%s\n%s','Cannot drag data from a graphic linked to more than one variable.',...
               'Please use copy and paste instead.'),...
               'MATLAB','modal');
         return
    end
    
    brushMgr = datamanager.BrushManager.getInstance();
    varName = linkedVarList{1};
    I = brushMgr.getBrushingProp(varName,mfile,fcnname,'I');
    brushColor = brushMgr.getBrushingProp(varName,mfile,fcnname,'Color');
    if ~isempty(I)       
        varValue = evalin('caller',[varName ';']);
    else
        return
    end
    
    % Create a transferable string to drop based on the current graphical
    % object rather than all items selected in the figure
    if isvector(varValue)
        Isel = datamanager.var2string(varValue(I));
    else
        Isel = datamanager.var2string(varValue(any(I,2),:));
    end

    % Start the drag 
    jf = datamanager.getJavaFrame(fig);
    AxesDragRecogniser.dragGestureRecognized(jf.getAxisComponent,...
        AxesDragRecogniser.createVariableDragImage(java.lang.String(varName),java.awt.Color(brushColor(1),brushColor(2),brushColor(3))),...
        Isel);

else 
    % Drag this object
    this.drag;
end