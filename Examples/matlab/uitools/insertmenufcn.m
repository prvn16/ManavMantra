function insertmenufcn(hfig, cmd)
% This function is undocumented and will change in a future release

%INSERTMENUFCN Implements part of the figure insert menu.
%  INSERTMENUFCN(CMD) invokes insert menu command CMD on figure GCBF.
%  INSERTMENUFCN(H, CMD) invokes insert menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    Xlabel
%    Ylabel
%    Zlabel
%    Title
%    Legend
%    Colorbar
%    DoubleArrow
%    Arrow
%    Line
%    Text
%    Textbox
%    Rectangle
%    Axes
%    Light

%  CMD Values For Internal Use Only:
%    InsertPost

%  Copyright 1984-2015 The MathWorks, Inc.

narginchk(1,2)

if nargin > 1
    cmd = convertStringsToChars(cmd);
end

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'InsertPost'
        LUpdateInsertMenu(hfig);
    case 'Xlabel'
        domymenu menubar addxlabel
    case 'Ylabel'
        domymenu menubar addylabel
    case 'Zlabel'
        domymenu menubar addzlabel
    case 'Title'
        domymenu menubar addtitle
    case 'Legend'
        lmenu = findall(hfig,'Tag','figMenuInsertLegend');
        ltogg = uigettool(hfig,'Annotation.InsertLegend');
        cax = get(hfig,'CurrentAxes');
        % Toggle controls change state prior to the callback execution
        % If no action is taken, reset the toggle state to 'off'
        disableToggle = false;
        if ~isempty(cax)
            turnOnLegend = (~isempty(lmenu) && isequal(lmenu,gcbo) && strcmpi(get(lmenu,'Checked'),'off')) ||...
                            (~isempty(ltogg) && isequal(ltogg,gcbo) && strcmpi(get(ltogg,'State'),'on'));
            if turnOnLegend
                % Check for a 'LegendVisible' property first (for charts that expose
                % a LegendVisible property
                if isprop(cax,'LegendVisible')
                    % Chart subclasses do not support undo/redo because we
                    % cannot provide a legend object handle
                    legend(cax);
                elseif isprop(cax,'Legend')
                    leg = legend(cax);
                    graph2dhelper('registerUndoLegendColorbar',leg);
                else
                    % the current axes does not support legend via either a
                    % LegendVisible or Legend property
                    disableToggle = true;             
                end
            else
                legend(cax,'off');
            end
        else
            % there was no current axes
            disableToggle = true;
        end
        
        if disableToggle && ~isempty(ltogg)
            set(ltogg,'State','off');
        end

    case 'Colorbar'
        cbmenu = findall(hfig,'Tag','figMenuInsertColorbar');
        cbtogg = uigettool(hfig,'Annotation.InsertColorbar');
        cax = get(hfig,'CurrentAxes');
        % Toggle controls change state prior to the callback execution
        % If no action is taken, reset the toggle state to 'off'
        disableToggle = false;
        if ~isempty(cax)
            turnOnColorbar = (~isempty(cbmenu) && isequal(cbmenu,gcbo) && strcmpi(get(cbmenu,'Checked'),'off')) ||...
                        (~isempty(cbtogg) && isequal(cbtogg,gcbo) && strcmpi(get(cbtogg,'State'),'on'));
            if turnOnColorbar
                % Check for a 'ColorbarVisible' property first (for charts that expose
                % a ColorbarVisible property)
                if isprop(cax,'ColorbarVisible')
                    % Chart subclasses do not support undo/redo because we
                    % cannot provide a colorbar object handle
                    colorbar(cax);
                elseif isprop(cax,'Colorbar')
                    cbar = colorbar('peer',cax);
                    graph2dhelper('registerUndoLegendColorbar',cbar);
                else
                    % the current axes does not support legend via either a
                    % ColorbarVisible or Colorbar property
                    disableToggle = true;
                end
            else
                colorbar(cax,'off');
            end
        else
            % there was no current axes
            disableToggle = true;
        end
            
        if disableToggle && ~isempty(cbtogg)
            set(cbtogg,'State','off');
        end
    case 'DoubleArrow'
        startscribeobject('doublearrow',hfig)
    case 'Arrow'
        startscribeobject('arrow',hfig)
    case 'TextArrow'
        startscribeobject('textarrow',hfig)
    case 'Line'
        startscribeobject('line',hfig)
    case 'Text'
        domymenu menubar addtext
    case 'Textbox'
        startscribeobject('textbox',hfig)
    case 'Rectangle'
        startscribeobject('rectangle',hfig)
    case 'Ellipse'
        startscribeobject('ellipse',hfig)
    case 'Axes'
        domymenu menubar addaxes
    case 'Light'
        domymenu menubar addlight
end

%-----------------------------------------------------------------------%
function LUpdateInsertMenu(fig)

insertMenuItems = allchild(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuInsert'));
if ~isempty(insertMenuItems)    
  if isappdata(fig, 'ScribePloteditEnable') && strcmp(getappdata(fig, 'ScribePloteditEnable'), 'off')
    eMenus = [findall(insertMenuItems, 'Tag', 'figMenuInsertAxes')
              findall(insertMenuItems, 'Tag', 'figMenuInsertEllipse')
              findall(insertMenuItems, 'Tag', 'figMenuInsertRectangle')
              findall(insertMenuItems, 'Tag', 'figMenuInsertTextbox')
              findall(insertMenuItems, 'Tag', 'figMenuInsertTextArrow')
              findall(insertMenuItems, 'Tag', 'figMenuInsertArrow2')
              findall(insertMenuItems, 'Tag', 'figMenuInsertArrow')
              findall(insertMenuItems, 'Tag', 'figMenuInsertLine')
              findall(insertMenuItems, 'Tag', 'figMenuInsertColorbar')
              findall(insertMenuItems, 'Tag', 'figMenuInsertLegend')
              findall(insertMenuItems, 'Tag', 'figMenuInsertTitle')
              findall(insertMenuItems, 'Tag', 'figMenuInsertXLabel')
              findall(insertMenuItems, 'Tag', 'figMenuInsertYLabel')
              findall(insertMenuItems, 'Tag', 'figMenuInsertZLabel')
              findall(insertMenuItems, 'Tag', 'figMenuInsertLight')];
    set(eMenus, 'Enable', 'off');
  else
    % Set Enable Flag values
    menuEnable='on';
    titleEnable = 'on';
    zLabelEnable = 'on';
    xyLabelEnable = 'on';
    if isempty(findobj(fig,'Type','axes','-or','Type','polaraxes'))
        % if no axes in figure, disable everything in menu
        menuEnable='off';
    else
        ax = get(fig,'CurrentAxes');
        if ~isempty(ax)
            tag = get(ax,'Tag');
            if strcmpi(tag,'legend') || strcmpi(tag,'Colorbar')
                % if current axes is a colorbar or legend, disable
                % X,Y,Z label and Title
                titleEnable='off';
                xyLabelEnable = 'off';
                zLabelEnable = 'off';
            elseif isa(ax,'matlab.graphics.axis.PolarAxes')
                xyLabelEnable = 'off';
                zLabelEnable = 'off';
            elseif is2D(ax)
                zLabelEnable='off';
            end   
        end
    end
    % Enable/Disable Menu Items
    % Use Cell array to maintain correct indexing
    eMenus= {findobj(insertMenuItems,'tag','figMenuInsertYLabel')
        findobj(insertMenuItems,'tag','figMenuInsertXLabel')
        findobj(insertMenuItems,'tag','figMenuInsertZLabel')
        findobj(insertMenuItems,'tag','figMenuInsertTitle')
        findobj(insertMenuItems,'tag','figMenuInsertLegend')
        findobj(insertMenuItems,'tag','figMenuInsertColorbar')
        findobj(insertMenuItems,'tag','figMenuInsertLight')
        findobj(insertMenuItems,'tag','figMenuInsertAxes')};
    if ~isempty(eMenus)
        % All items present set to menu enable
        set([eMenus{1:7}],'Enable',menuEnable);
        if strcmpi(menuEnable,'on')
            if strcmpi(xyLabelEnable,'off')
                set([eMenus{1:2}],'Enable',xyLabelEnable);
            end
            if strcmpi(zLabelEnable,'off')
                set(eMenus{3},'Enable',zLabelEnable);
            end
            if strcmpi(titleEnable,'off')
                set(eMenus{4},'Enable',titleEnable);
            end
        end
    end
    % Always enable insert axes;
    set(eMenus{8},'Enable','on');
  end
end

