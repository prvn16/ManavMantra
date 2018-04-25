function brushHGCallback(es,ed,colorChooser) %#ok<INUSL>

% Callback for expand button on brush uitogglesplittool. Creates a
% ColorPickerPanel panel and parents it the first time the button is
% expanded and removes the "Building..." splash menu. This function is
% needed because of the high 'cold start' time for the ColorChooser inside
% the uitogglesplittool.

if nargin>=3 
    % Called from FigureColorChooser.java in response to
    % addTouitogglesplittool (below)
    f = ancestor(es,'figure');
    modeAccessor = brush(f);
    colorChooser.fUddObject = java(modeAccessor);
    %es = uigettool(f,'Exploration.Brushing');
    es = uigettool(findall(f,'type','uitoolbar'),'Exploration.Brushing');
    hContainer = get(handle(es),'JavaContainer');
    buildingMenu = allchild(es);
    
    colorChooserComponent = javacomponent(colorChooser,[0 0 0 0],es);
    
    % Pack and repaint color chooser 
    colorChooser.packPopup(hContainer.getComponentPeer.getPopupMenu);
    awtinvoke(colorChooser,'revalidate()');
    awtinvoke(colorChooser,'repaint()');
    setappdata(es,'javaComponent',colorChooserComponent);
    
    % Remove the "Building..." splash menu
    if ~isempty(buildingMenu)
        delete(buildingMenu)
    end
    return
end

colorChooserComponent = getappdata(es,'javaComponent');
if isempty(colorChooserComponent) || ~ishandle(colorChooserComponent)
    modeAccessor = brush(ancestor(es,'figure'));
    colorChooser = awtcreate('com.mathworks.page.datamgr.brushing.FigureColorChooser',...
        'Ljava.lang.Object;',java(modeAccessor)); 
    colorChooserComponent = javacomponent(colorChooser,[0 0 0 0],es);
    setappdata(es,'javaComponent',colorChooserComponent);

    % Remove the "Building..." splash menu
    buildingMenu = allchild(es);
    if ~isempty(buildingMenu)
       delete(buildingMenu)
    end
end


