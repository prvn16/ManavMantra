function exportsetupdlg(fig)
%EXPORTSETUPDLG Figure style editor
%  EXPORTSETUPDLG launches a dialog to edit the current figure's
%  export settings.
%  EXPORTSETUPDLG(FIG) edits the export settings for figure FIG.
%
%  See also: HGEXPORT, PRINT

%   Copyright 1984-2017 The MathWorks, Inc.

% If there is no figure passed in, use the current one (create if needed).
if nargin == 0
  fig = gcf;
end

% Error out if swing is not available.  Message shown:
%   ??? The export setup dialog is not supported on this platform.
error(javachk('swing','The export setup dialog'));

% Create the dynamic property "ExportsetupWindow".
FigHandle = handle(fig);
if ~ishghandle(FigHandle,'figure')
  error(message('MATLAB:exportsetupdlg:invalidFigure'));
end
addExportsetupdlgDynamicProperties(FigHandle);

% Reuse window if one exists (and hold on to handles for callbacks also).
fig = double(fig);
ui = getui(fig);

% If we don't have a ui, create it.
noui = isempty(ui);
if noui
  ui = createui(fig);
end

% Turn off the ui while we update.
ui.active = false; 
setui(fig,ui);

% Get the path to the styles directory; if it doesn't exist, 
% create it.
pathname = getStyleDir;
if ~exist(pathname,'dir')
  mkdir(pathname);
  initStandardStyles(pathname);
end

% Get the figure's current style; if it's empty, use a default.
style = getappdata(fig,'Exportsetup');
if isempty(style)
  try      
    style = hgexport('readstyle','Default');
  catch ex %#ok<*NASGU>
    style = hgexport('factorystyle');
  end
end
ui.style = style;
ui.styles = getStyles;

% If ui is empty, set the figure, clear the dirty flag and load the styles. 
if noui
  ui.figure = fig;
  clearDirty(ui);
  ui = loadstyle(style,ui);
  if ~ishghandle(fig), return; end
end

% Bring up the dialog.
setui(fig,ui);
ui.win.setName('ExportSetupDialog');
awtinvoke(ui.win,getMethod(getClass(ui.win),'toFront',[]));
drawnow;

% Set the dialog to not resize (why?) and set it visible .
if ~ishghandle(fig), return; end
ui.win.setResizable(0);
awtinvoke(ui.win,'setVisible(Z)',true,@activateWindow,fig);

% Sets the ui as active.
function activateWindow(fig)
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  ui.active = true;
  setui(fig,ui);

%---------------------------  Style Loading -----------------------
function ui=loadstyle(style,ui)
  % Initialize variables.
  ui.style = style;
  ui.active = false;
  setui(ui.figure,ui);
  
  % Set up the dialog title "Export Setup: Figure <n>".
  wintitle = getString(message('MATLAB:exportsetupdlg:ExportSetupTitle'));
  name = get(ui.figure,'Name');
  if ~isempty(name)
    wintitle = [wintitle ': ' name];
  elseif strcmp(get(ui.figure,'NumberTitle'),'on')
    wintitle = [wintitle ': Figure ' num2str(double(ui.figure))];
  end
  awtinvoke(ui.win,'setTitle(Ljava/lang/String;)',...
            java.lang.String(wintitle));
        
  % Set the initial panel to "Size".
  awtinvoke(ui.panelchoice,'setSelectedIndex(I)',0);
  awtinvoke(ui.cardlayout,'show(Ljava/awt/Container;Ljava/lang/String;)',...
            ui.cardpane,java.lang.String('Size'));
        
  % Set the combobox for "Load settings from" to "default".
  awtinvoke(ui.selectstylebutton,'setModel(Ljavax/swing/ComboBoxModel;)',...
            getStyleComboBoxModel(ui.styles));
  
  % Disable the "Restore Figure" pushbutton for now (we haven't done
  % anthing to the figure yet to have to restore.
  awtinvoke(ui.restorebutton,'setEnabled(Z)',~isempty(ui.oldstate));
  
  % Load the various properties panels.
  ui=loadsizepanel(style,ui);
  loadrenderingpanel(style,ui);
  loadfontpanel(style,ui);
  loadlinepanel(style,ui);

  % Draw the dialog, set ui.active (if figure exists), clear dirty flag.
  drawnow;
  if ~ishghandle(ui.figure), return; end
  ui.active = true;
  clearDirty(ui);

  
function comboModel = getStyleComboBoxModel(styles)
% This returns a DefaultComboBoxModel with the style options. 
% We replace the entries 'MSWord' and 'PowerPoint'
% with 'Documents' and 'Presentations'. See g830438

  for k = 1:length(styles)
      if strcmp(styles{k},'MSWord')
          styles{k} = getString(message('MATLAB:exportsetupdlg:Documents'));
      end
      if strcmp(styles{k},'PowerPoint')
          styles{k} = getString(message('MATLAB:exportsetupdlg:Presentations'));
      end
  end
  comboModel = javax.swing.DefaultComboBoxModel(styles);
  
    

% Initialize the "Size" panel.
function ui=loadsizepanel(style,ui)
  ui.widthitems = updateEditableComboBox(style.Width,...
                                         ui.widthitems,ui.widthtext,true);
  ui.heightitems = updateEditableComboBox(style.Height,...
                                          ui.heightitems,ui.heighttext,true);
  [vals,~] = getUnitsVals; 
  ind = find(strcmpi(style.Units,vals));
  % Set units to first choice.
  if ~isempty(ind)
    awtinvoke(ui.unitsbutton,'setSelectedIndex(I)',ind-1);
  end  
  % Set "expand axes to fill figure".
  awtinvoke(ui.boundsbutton,'setSelected(Z)',...
            isequal(style.Bounds,'tight'));

% Initialize the "Rendering" panel.
function loadrenderingpanel(style,ui)
  % Initialize colorspace
  color = style.Color;
  [colors, ~] = getColorVals;
  ind = find(strcmpi(color,colors));
  if ~isempty(ind)
    awtinvoke(ui.colorbutton,'setSelectedIndex(I)',ind-1);
  end
  backcolor = style.Background;
  awtinvoke(ui.backcolorcustombutton,'setSelected(Z)', ~isempty(backcolor));
  awtinvoke(ui.backcolortext,'setText(Ljava/lang/String;)',...
            java.lang.String(backcolor));
  val = style.Resolution;
  if ~isempty(val) && ~strcmp('auto',val)
    val = num2str(val); 
  end
  
  % Initialize renderer.
  ui.resitems = updateEditableComboBox(val,ui.resitems,ui.restext,true);
  ind = find(strcmpi(style.Renderer,getRendererVals));
  if ~isempty(ind)
    awtinvoke(ui.rendererbutton,'setSelectedIndex(I)',ind-1);
  else
    awtinvoke(ui.rendererbutton,'setSelectedIndex(I)',0);  
  end
  rend = style.Renderer;
  awtinvoke(ui.rendercustombutton,'setSelected(Z)',...
            ~isempty(rend) && ~isequal(rend,'auto'));
        
  % Initialize "Keep axis limit" and "Show uicontrols" checkboxes.
  awtinvoke(ui.lockbutton,'setSelected(Z)',...
            isequal(style.LockAxes,'on'));
  awtinvoke(ui.showuibutton,'setSelected(Z)',...
            isequal(style.ShowUI,'on'));

% Initialize the "Fonts" panel.
function loadfontpanel(style,ui)
  % Initialize "Custom size" and "Scale/Use" radiobuttons.
  switch style.FontMode
   case 'none'
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',false);
   case 'scaled'
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    awtinvoke(ui.fontmodescale,'setSelected(Z)',true);
   case 'fixed'
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    awtinvoke(ui.fontmodefix,'setSelected(Z)',true);
  end
  
  awtinvoke(ui.fontscale,'setText(Ljava/lang/String;)',...
            java.lang.String(style.ScaledFontSize));
  awtinvoke(ui.fontmin,'setText(Ljava/lang/String;)',...
            java.lang.String(num2str(style.FontSizeMin)));
  awtinvoke(ui.fontfix,'setText(Ljava/lang/String;)',...
            java.lang.String(num2str(style.FixedFontSize)));
        
  % Font name.
  fontname = style.FontName;
  awtinvoke(ui.fontnamecustom,'setSelected(Z)', ...
            ~isempty(fontname) && ~strcmp(fontname,'auto'));
  ind = find(strcmpi(style.FontName,ui.fontlist));
  if ~isempty(ind)
    awtinvoke(ui.fontnametext,'setSelectedIndex(I)',ind-1);
  else
    ind = find(strcmpi('helvetica',ui.fontlist));
    if isempty(ind)
      ind = find(strcmpi('ariel',ui.fontlist));
    end
    awtinvoke(ui.fontnametext,'setSelectedIndex(I)',ind-1);
  end
  fontweight = style.FontWeight;
  
  % Font weight.
  awtinvoke(ui.fontweightcustom,'setSelected(Z)', ...
            ~isempty(fontweight) && ~strcmp(fontweight,'auto'));
  [vals,~] = getWeightVals; 
  ind = find(strcmpi(fontweight,vals));
  if ~isempty(ind)
    awtinvoke(ui.weightbutton,'setSelectedIndex(I)',ind-1);
  else
    awtinvoke(ui.weightbutton,'setSelectedIndex(I)',0);
  end
  
  % Font angle.
  fontangle = style.FontAngle;
  awtinvoke(ui.fontanglecustom,'setSelected(Z)', ...
            ~isempty(fontangle) && ~strcmp(fontangle,'auto'));
  [vals,~] = getAngleVals;
  ind = find(strcmpi(fontangle,vals));
  if ~isempty(ind)
    awtinvoke(ui.anglebutton,'setSelectedIndex(I)',ind-1);
  else
    awtinvoke(ui.anglebutton,'setSelectedIndex(I)',0);
  end

% Initialize the "Lines" panel.
function loadlinepanel(style,ui)
  % Initialize "Custom width" and "Scale/Use" radiobuttons.
  switch style.LineMode
   case 'none'
    awtinvoke(ui.linemodecustom,'setSelected(Z)',false);
   case 'scaled'
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    awtinvoke(ui.linemodescale,'setSelected(Z)',true);
   case 'fixed'
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    awtinvoke(ui.linemodefix,'setSelected(Z)',true);
  end
  awtinvoke(ui.linescale,'setText(Ljava/lang/String;)',...
            java.lang.String(style.ScaledLineWidth));
  awtinvoke(ui.linemin,'setText(Ljava/lang/String;)',...
            java.lang.String(num2str(style.LineWidthMin)));
  awtinvoke(ui.linefix,'setText(Ljava/lang/String;)',...
            java.lang.String(num2str(style.FixedLineWidth)));
  awtinvoke(ui.stylebutton,'setSelected(Z)',...
            isequal(style.LineStyleMap,'bw'));

%---------------------------  Dialog Creation  -----------------------
% ExportsetupWindow is a dynamic property on the figure that has the
% following structure/model for this dialog:
%
%                       esd: [1x1 com.mathworks.page.export.ExportSetupDialog]
%                            %% This dialog.
%                       win: [1x1 com.mathworks.mwswing.MJFrame]
%                            %% The frame for this dialog.
%               panelchoice: [1x1 com.mathworks.mwswing.MJList]
%                            %% Size, Rendering, Fonts or Lines.
%                  cardpane: [1x1 com.mathworks.mwswing.MJPanel]
%                            %% Panel for properties for a particular choice.
%                cardlayout: [1x1 java.awt.CardLayout]
%                            %% Layout manager.
%                  oldstate: []
%                            %% Previous state.
%
% Properties panel, Size:
%                widthitems: {'auto'}
%                            %% Default width.
%               heightitems: {'auto'}
%                            %% Default height.
%                 widthtext: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% "Width" choices.
%               unitsbutton: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% "Units" choices (inches, centimeters,
%                            %% points).
%                heighttext: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% "Height" choices.
%              boundsbutton: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Expand axes to fill figure" checkbox.
%
% Properties panel, Rendering:
%                  resitems: {'screen'  '150'  '300'  '600'  'auto'}
%               colorbutton: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% "Colorspace" choices (black and white, 
%                            %% grayscale, RGB Color, CMYK color).
%             backcolortext: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Custom color" text box.
%     backcolorcustombutton: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom color" checkbox.
%            rendererbutton: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% "Custom renderer" choices (painters,
%                            %% OpenGL, zbuffer).
%        rendercustombutton: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom renderer" checkbox
%                   restext: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% "Resolution (dpi)" choices (see
%                            %% resitems above).
%                lockbutton: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Keep axis limits" checkbox.
%              showuibutton: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Show uicontrols" checkbox.
%
% Properties panel, Fonts:
%                  fontlist: {187x1 cell}
%                            %% All of the currently supported fonts.
%            fontmodecustom: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom size" checkbox.
%             fontmodescale: [1x1 com.mathworks.mwswing.MJRadioButton]
%                            %% "Scale font by" radiobutton.
%                 fontscale: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Scale font by" percentage (default
%                            %% is auto).
%                   fontmin: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Scale font by" minimum size in points.
%               fontmodefix: [1x1 com.mathworks.mwswing.MJRadioButton]
%                            %% "Used fixed font size" radiobutton.
%                   fontfix: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Used fixed font size" size in points.
%            fontnamecustom: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom name" checkbox
%              fontnametext: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% Name choices (uses fontlist above)
%          fontweightcustom: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom weight" checkbox
%              weightbutton: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% Weight choices (normal, light, demi,
%                            %% bold)
%           fontanglecustom: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom angle" checkbox
%               anglebutton: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% Angle choices (normal, italic,
%                            %% oblique).
%
% Properties panel, Lines:
%            linemodecustom: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Custom width" checkbox.
%             linemodescale: [1x1 com.mathworks.mwswing.MJRadioButton]
%                            %% "Scale line width by" radiobutton.
%                 linescale: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Scale line width by" percentage (default
%                            %% is auto).
%                   linemin: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Scale line width by" minimum in points.
%               linemodefix: [1x1 com.mathworks.mwswing.MJRadioButton]
%                            %% "Use fixed line width" radiobutton
%                   linefix: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% "Use fixed line width size in points.
%               stylebutton: [1x1 com.mathworks.mwswing.MJCheckBox]
%                            %% "Convert solid lines to cycle through
%                            %% line styles" checkbox.
%
% Export Styles panel:
%                    styles: {'default'  'MSWord'  'PowerPoint'}
%                            %% Default styles for exporting.
%         selectstylebutton: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% Combobox that contains the above styles.
%           loadstylebutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Load pushbutton
%                  savetext: [1x1 com.mathworks.mwswing.MJTextField]
%                            %% Textfield to name custom style
%                savebutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Save pushbutton
%           deletestylelist: [1x1 com.mathworks.mwswing.MJComboBox]
%                            %% Combobox containing all styles available.
%              deletebutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Delete pushbutton
%
% Button panel:
%               applybutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Apply to Figure pushbutton
%             restorebutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Restore Figure pushbutton
%              exportbutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Export... pushbutton
%                  okbutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% OK pushbutton
%               closebutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Really the Cancel pushbutton
%                helpbutton: [1x1 com.mathworks.mwswing.MJButton]
%                            %% Help pushbutton
%                    active: 1
%                            %% Active or inactive
%                     style: [1x1 struct]
%                            %%
%                    figure: 1
%                            %% Figure handle
function ui = createui(fig)

  % Create the "properties" pane.
  [panes,tabstrs] = getTabs; %#ok
  esd = com.mathworks.page.export.ExportSetupDialog;
  esd.createWindow(tabstrs, getString(message('MATLAB:exportsetupdlg:PropertiesPanel')));

  ui.esd = esd;
  % pull fields out of the java class
  ui.win = javaObjectEDT(esd.win);
  ui.panelchoice =  javaObjectEDT(esd.panelchoice);
  ui.cardpane =  javaObjectEDT(esd.cardpane);
  ui.cardlayout =  javaObjectEDT(esd.cardlayout);

  % Initialize the oldstate and get the handle to the figure
  ui.oldstate = [];
  hfig = handle(fig);
  
  % Assuming that the listeners created below need to be around as long as
  % the figure is alive.
  ui.listeners{1} = addlistener(hfig, ...
      'Visible','PostSet',@(o,e)doCloseForce(o,e,fig));
  ui.listeners{2} = addlistener(hfig, ...
      'ObjectBeingDestroyed',@(o,e) doCloseForce(o,e,fig));
  
  % Set a callback on the properties choice window so we bring up the 
  % right panel for the right choice (Size, Rendering, Fonts or Lines).
  set(handle(ui.panelchoice,'callbackproperties'), ...
      'ValueChangedCallback',{@doPanelChoice,fig});

  % Create all the panels.
  ui = createsizepanel(ui,fig);
  ui = createrenderpanel(ui,fig);
  ui = createfontpanel(ui,fig);
  ui = createlinepanel(ui,fig);
  ui = createStyleLoadSave(ui,fig);
  ui = createOKCancel(ui,fig);

  screen = get(0,'ScreenSize');
  if strcmp(get(fig,'WindowStyle'),'docked')
    x = (screen(3)/2) - 200;
    y = (screen(4)/2) - 200;
  else
    pos = hgconvertunits(fig,get(fig,'Position'), ...
              get(fig,'Units'),...
              'pixels',get(fig, 'Parent'));
    x = pos(1)+20;
    y = screen(4)-pos(2)-pos(4)+200;
    if y < 0, y = 0; end
  end

  esd.assembleWindow(x, y);



% Create the panel for "Export Styles".
function ui = createStyleLoadSave(ui,fig)
  ui.styles = getStyles;

  styles = ui.styles;
  styles(strcmp(xdefault,styles)) = [];
  styles(strcmp('PowerPoint',styles)) = [];
  styles(strcmp('MSWord',styles)) = [];
  
  % If there are no custom styles, disable the Delete button.
  enableDelete = ~isempty(styles);

  if isempty(styles), styles = {' '}; end

  ui.esd.createStyleLoadSavePanel(ui.styles, styles, enableDelete, ...
                                  getString(message('MATLAB:exportsetupdlg:ExportStylesPanel')), ...
                                  getString(message('MATLAB:exportsetupdlg:LoadButton')), getString(message('MATLAB:exportsetupdlg:LoadSettingsFromLabel')), ...
                                  getString(message('MATLAB:exportsetupdlg:SaveAsStyleNamedLabel')), xdefault, ...
                                  getString(message('MATLAB:exportsetupdlg:SaveButton')), getString(message('MATLAB:exportsetupdlg:DeleteAStyleLabel')), ...
                                  getString(message('MATLAB:exportsetupdlg:DeleteButton')));
  
  ui.selectstylebutton =  javaObjectEDT(ui.esd.selectstylebutton);
  ui.selectstylebutton.setModel(getStyleComboBoxModel(ui.styles))

  % Load
  ui.loadstylebutton =  javaObjectEDT(ui.esd.loadstylebutton);
  set(handle(ui.loadstylebutton, 'callbackproperties'), ...
      'actionPerformedCallback', {@doLoadStyle,fig});

  % Save
  ui.savetext =  javaObjectEDT(ui.esd.savetext);
  ui.savebutton =  javaObjectEDT(ui.esd.savebutton);
  set(handle(ui.savebutton, 'callbackproperties'), ...
      'actionPerformedCallback',{@doSave,fig});

  % Delete
  ui.deletestylelist = javaObjectEDT(ui.esd.deletestylelist);
  ui.deletebutton =  javaObjectEDT(ui.esd.deletebutton);
  set(handle(ui.deletebutton, 'callbackproperties'), ...
      'actionPerformedCallback',{@doDelete,fig});


% Create the panel for the buttons.
function ui = createOKCancel(ui,fig)
  ui.esd.createOKCancelPanel(getString(message('MATLAB:exportsetupdlg:ApplyToFigureButton')), getString(message('MATLAB:exportsetupdlg:RestoreFigureButton')), ...
                                  getString(message('MATLAB:exportsetupdlg:ExportButton')), getString(message('MATLAB:exportsetupdlg:OKButton')), getString(message('MATLAB:exportsetupdlg:CancelButton')), ...
                                  getString(message('MATLAB:exportsetupdlg:HelpButton')));

  ui.applybutton =  javaObjectEDT(ui.esd.applybutton);
  ui.restorebutton =  javaObjectEDT(ui.esd.restorebutton);
  ui.exportbutton =  javaObjectEDT(ui.esd.exportbutton);
  ui.okbutton =  javaObjectEDT(ui.esd.okbutton);
  ui.closebutton =  javaObjectEDT(ui.esd.closebutton);
  ui.helpbutton =  javaObjectEDT(ui.esd.helpbutton);

  set(handle(ui.applybutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@doApply,fig});
  set(handle(ui.restorebutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@doRestore,fig});
  set(handle(ui.exportbutton,'CallbackProperties'), ...
     'actionPerformedCallback',{@doExport,fig});
  set(handle(ui.okbutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@doOK,fig});
  set(handle(ui.closebutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@doCancel,fig});
  set(handle(ui.helpbutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@doHelp,fig});

  
% Create the panel for the "Size" property choice.
function ui = createsizepanel(ui,fig)
  ui.widthitems = {xauto};
  ui.heightitems = {xauto};
  [unitsvals,unitsstrs] = getUnitsVals; %#ok
  ui.esd.createSizePanel(ui.widthitems, ['  ',getString(message('MATLAB:exportsetupdlg:WidthLabel'))], ...
                         unitsstrs, ['  ',getString(message('MATLAB:exportsetupdlg:UnitsLabel'))], ...
                         ui.heightitems, ['  ',getString(message('MATLAB:exportsetupdlg:HeightLabel'))], ...
                         getString(message('MATLAB:exportsetupdlg:ExpandAxesToFillFigureCheckBox')));
                     
  % Width
  ui.widthtext =  javaObjectEDT(ui.esd.widthtext);
  set(handle(ui.widthtext,'callbackProperties'), ...
      'actionPerformedCallback',{@widthChanged,fig});
  set(handle(ui.widthtext,'callbackProperties'), ...
      'focusLostCallback',{@widthChanged,fig});

  % Units
  ui.unitsbutton =  javaObjectEDT(ui.esd.unitsbutton);
  set(handle(ui.unitsbutton,'callbackProperties'), ...
      'actionPerformedCallback',{@unitsChanged,fig});

  % Height 
  ui.heighttext =  javaObjectEDT(ui.esd.heighttext);
  set(handle(ui.heighttext,'callbackProperties'), ...
      'actionPerformedCallback',{@heightChanged,fig});
  set(handle(ui.heighttext,'callbackProperties'), ...
      'focusLostCallback',{@heightChanged,fig});

  % "Expand axes to fill figure" bounds button 
  ui.boundsbutton =  javaObjectEDT(ui.esd.boundsbutton);
  set(handle(ui.boundsbutton,'callbackProperties'), ...
      'actionPerformedCallback',{@boundsChanged,fig});

% Create the panel for the "Rendering" property choice.
function ui = createrenderpanel(ui,fig)
  [colors,colorstrs] = getColorVals; %#ok
  [rends,renderstrs] = getRendererVals; %#ok
  ui.resitems = {xscreen,'150','300','600',xauto};

  ui.esd.createRenderPanel(colorstrs, ['  ',getString(message('MATLAB:exportsetupdlg:ColorspaceLabel'))], getString(message('MATLAB:exportsetupdlg:CustomColorCheckBox')), ...
                           renderstrs, getString(message('MATLAB:exportsetupdlg:CustomRendererCheckBox')), ...
                           ui.resitems, ['  ',getString(message('MATLAB:exportsetupdlg:ResolutiondpiLabel'))], ...
                           getString(message('MATLAB:exportsetupdlg:KeepAxisLimitsCheckBox')), getString(message('MATLAB:exportsetupdlg:ShowUicontrolsCheckBox')));

  ui.colorbutton =  javaObjectEDT(ui.esd.colorbutton);
  set(handle(ui.colorbutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@colorChanged,fig});

  % "Colorspace" background color
  ui.backcolortext =  javaObjectEDT(ui.esd.backcolortext);
  set(handle(ui.backcolortext,'CallbackProperties'), ...
      'actionPerformedCallback',{@backcolorChanged,fig});
  set(handle(ui.backcolortext,'CallbackProperties'), ...
      'focusLostCallback',{@backcolorChanged,fig});
  ui.backcolorcustombutton =  javaObjectEDT(ui.esd.backcolorcustombutton);
  set(handle(ui.backcolorcustombutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@backcolorcustomChanged,fig});

  % Renderer
  ui.rendererbutton =  javaObjectEDT(ui.esd.rendererbutton);
  set(handle(ui.rendererbutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@rendererChanged,fig});

  ui.rendercustombutton =  javaObjectEDT(ui.esd.rendercustombutton);
  set(handle(ui.rendercustombutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@rendercustomChanged,fig});

  % Resolution
  ui.restext =  javaObjectEDT(ui.esd.restext);
  set(handle(ui.restext,'CallbackProperties'), ...
      'actionPerformedCallback',{@resChanged,fig});
  set(handle(ui.restext,'CallbackProperties'), ...
      'focusLostCallback',{@resChanged,fig});

  % "Keep axis limits" lock button
  ui.lockbutton =  javaObjectEDT(ui.esd.lockbutton);
  set(handle(ui.lockbutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@lockChanged,fig});
  
  % Showui button
  ui.showuibutton =  javaObjectEDT(ui.esd.showuibutton);
  set(handle(ui.showuibutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@showuiChanged,fig});

% Create the panel for the "Fonts" property choice.
function ui = createfontpanel(ui,fig)
  ui.fontlist = listfonts;
  [vals,fontweightstrs] = getWeightVals; %#ok
  [vals,fontanglestrs] = getAngleVals; %#ok
  ui.esd.createFontPanel(getString(message('MATLAB:exportsetupdlg:CustomSizeCheckBox')), ...
                         [getString(message('MATLAB:exportsetupdlg:ScaleFontByLabel')),' ',], ...
                         ['       ',getString(message('MATLAB:exportsetupdlg:WithMinimumOfLabel')),' '], ...
                         [' ',getString(message('MATLAB:exportsetupdlg:PointsDropdown'))], ...
                         [getString(message('MATLAB:exportsetupdlg:UseFixedFontSizeLabel')),' ',], ...
                         getString(message('MATLAB:exportsetupdlg:CustomNameCheckBox')), ...
                         ui.fontlist, ...
                         getString(message('MATLAB:exportsetupdlg:CustomWeightCheckBox')), ...
                         fontweightstrs, ...
                         getString(message('MATLAB:exportsetupdlg:CustomAngleCheckBox')), ...
                         fontanglestrs ...
                         );

  % Custom size
  ui.fontmodecustom =  javaObjectEDT(ui.esd.fontmodecustom);
  set(handle(ui.fontmodecustom,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontmodecustomChanged,fig});

  ui.fontmodescale =  javaObjectEDT(ui.esd.fontmodescale);
  set(handle(ui.fontmodescale,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontmodescaleChanged,fig});

  ui.fontscale =  javaObjectEDT(ui.esd.fontscale);
  set(handle(ui.fontscale,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontscaleChanged,fig});
  set(handle(ui.fontscale,'CallbackProperties'), ...
      'focusLostCallback',{@fontscaleChanged,fig});

  ui.fontmin =  javaObjectEDT(ui.esd.fontmin);
  set(handle(ui.fontmin,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontminChanged,fig});
  set(handle(ui.fontmin,'CallbackProperties'), ...
      'focusLostCallback',{@fontminChanged,fig});

  ui.fontmodefix =  javaObjectEDT(ui.esd.fontmodefix);
  ui.fontfix =  javaObjectEDT(ui.esd.fontfix);
  set(handle(ui.fontfix,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontfixChanged,fig});
  set(handle(ui.fontfix,'CallbackProperties'), ...
      'focusLostCallback',{@fontfixChanged,fig});

  % FontName
  ui.fontnamecustom =  javaObjectEDT(ui.esd.fontnamecustom);
  set(handle(ui.fontnamecustom,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontnamecustomChanged,fig});
  ui.fontnametext =  javaObjectEDT(ui.esd.fontnametext);
  set(handle(ui.fontnametext,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontnameChanged,fig});

  % FontWeight
  ui.fontweightcustom =  javaObjectEDT(ui.esd.fontweightcustom);
  set(handle(ui.fontweightcustom,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontweightcustomChanged,fig});
  ui.weightbutton =  javaObjectEDT(ui.esd.weightbutton);
  set(handle(ui.weightbutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@weightChanged,fig});

  % FontAngle
  ui.fontanglecustom =  javaObjectEDT(ui.esd.fontanglecustom);
  set(handle(ui.fontanglecustom,'CallbackProperties'), ...
      'actionPerformedCallback',{@fontanglecustomChanged,fig});
  
  ui.anglebutton =  javaObjectEDT(ui.esd.anglebutton);
  set(handle(ui.anglebutton,'CallbackProperties'), ...
      'actionPerformedCallback',{@angleChanged,fig});

% Create the panel for the "Lines" property choice.
function ui = createlinepanel(ui,fig)
  ui.esd.createLinePanel(getString(message('MATLAB:exportsetupdlg:CustomWidthCheckBox')), ...
                         [getString(message('MATLAB:exportsetupdlg:ScaleLineWidthByLabel')), ' '],...
                         ['       ',getString(message('MATLAB:exportsetupdlg:WithMinimumOfLabel')),' '], ...
                         [' ',getString(message('MATLAB:exportsetupdlg:PointsDropdown'))], ...
                         [getString(message('MATLAB:exportsetupdlg:UseFixedLineWidthLabel')),' '], ...
                         getString(message('MATLAB:exportsetupdlg:ConvertSolidLinesCheckBox')) ...
                     );
                
  % Custom width.
  ui.linemodecustom =  javaObjectEDT(ui.esd.linemodecustom);
  setcallback(ui.linemodecustom,'actionPerformedCallback',{@linemodecustomChanged,fig});

  ui.linemodescale =  javaObjectEDT(ui.esd.linemodescale);
  setcallback(ui.linemodescale,'actionPerformedCallback',{@linemodescaleChanged,fig});

  ui.linescale =  javaObjectEDT(ui.esd.linescale);
  setcallback(ui.linescale,'actionPerformedCallback',{@linescaleChanged,fig});
  setcallback(ui.linescale,'focusLostCallback',{@linescaleChanged,fig});

  ui.linemin =  javaObjectEDT(ui.esd.linemin);
  setcallback(ui.linemin,'actionPerformedCallback',{@lineminChanged,fig});
  setcallback(ui.linemin,'focusLostCallback',{@lineminChanged,fig});

  ui.linemodefix =  javaObjectEDT(ui.esd.linemodefix);
  setcallback(ui.linemodefix,'actionPerformedCallback',{@linemodefixChanged,fig});

  ui.linefix =  javaObjectEDT(ui.esd.linefix);
  setcallback(ui.linefix,'actionPerformedCallback',{@linefixChanged,fig});
  setcallback(ui.linefix,'focusLostCallback',{@linefixChanged,fig});

  % Style button
  ui.stylebutton =  javaObjectEDT(ui.esd.stylebutton);
  setcallback(ui.stylebutton,'actionPerformedCallback',{@styleChanged,fig});


%---------------------------  Callbacks  -----------------------

% Coordinate properties choice with the correct panel
function doPanelChoice(hSrc, eventData, fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    ind = getSelectedIndex(ui.panelchoice);
    [tabs,~] = getTabs; 
    awtinvoke(ui.cardlayout,'show(Ljava/awt/Container;Ljava/lang/String;)',...
              ui.cardpane,java.lang.String(tabs{ind+1}));
  end

% Load up the styles.
function doLoadStyle(hSrc, eventData, fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    ind = getSelectedIndex(ui.selectstylebutton);
    stylename = ui.styles{ind+1};
    if strcmp(stylename,xdefault)
        stylename = 'default';
    end

    if strcmpi(stylename,'default')
      ui.style = hgexport('factorystyle');
    else
      try
        ui.style = hgexport('readstyle',stylename);
      catch ex
        errordlg(sprintf(getString(message('MATLAB:exportsetupdlg:UnableToLoadStyleErrorDlg', stylename))));
        return;
      end
    end
    ui.active = false;
    setui(fig,ui);
    loadstyle(ui.style,ui);
  end

% Apply changes to the figure.
function doApply(hSrc, eventData,fig)
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ~isempty(ui.figure) && ishghandle(ui.figure)
    drawnow;
    if ~ishghandle(fig), return; end
    
    % Flush out the old changes and set the current figure as old,
    % before we apply the new changes.
    if ~isempty(ui.oldstate)
      doRestore(hSrc,eventData,fig);
    end
    try
      ui.oldstate = hgexport(ui.figure,tempname,ui.style,'applystyle', true);
    catch ex
      hErrorDlg = errordlg(ex.getReport('basic'),getString(message('MATLAB:exportsetupdlg:ExportSetupTitle')));
      set(hErrorDlg, 'WindowStyle', 'modal');
      return;
    end
    drawnow;
    if ~ishghandle(fig), return; end
    setappdata(ui.figure,'ExportsetupApplied',true);
    setappdata(ui.figure,'Exportsetup',ui.style)
  end
  setui(fig,ui);
  
  % We changed something, so we can restore the old values if needed.
  awtinvoke(ui.restorebutton,'setEnabled(Z)',true);

% Restores the figure back to what it was.
function doRestore(hSrc, eventData,fig) %#ok<INUSL>
  % No figure, nothing to do.
  if ~ishghandle(fig), return; end
  
  % Get the ui.
  ui = getui(fig);
  
  % Restore the old values.
  if ~isempty(ui.figure) && ishghandle(ui.figure) && ~isempty(ui.oldstate)
      drawnow;
      if ~ishghandle(fig), return; end
      old = ui.oldstate;
      restoreExport(old);   
  end
  
  % Empty out the old state and remove from the figure, 
  % since we backed out from the changes.
  ui.oldstate = [];
  if ~isempty(ui.figure) && ishghandle(ui.figure)
      try
          rmappdata(ui.figure,'ExportsetupApplied');
      catch ex
      end
  end
  
  % Set the ui and disable the restore button (we can only
  % restore if we've changed something).
  setui(fig,ui);
  awtinvoke(ui.restorebutton,'setEnabled(Z)',false);
  drawnow;

% Export the changed figure.
function doExport(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    oldstyle = getappdata(fig,'Exportsetup');
    if isempty(oldstyle)
      setappdata(fig,'Exportsetup',ui.style);
    end
    filemenufcn(fig,'FileExportAs');
    if isempty(oldstyle)
      try
        rmappdata(fig,'Exportsetup');
      catch ex
      end
    end
    % Bring Export Setup Window in front of the Figure after printing
    awtinvoke(ui.win,getMethod(getClass(ui.win),'toFront',[]));  
  end
  
% Delete a style.
function doDelete(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if ~ishghandle(fig), return; end
    
    % Try to find the style and delete it.
    path = getStyleDir;
    name = char(getSelectedItem(ui.deletestylelist));
    try
      delete(fullfile(path,[name '.txt']));
    catch ex
    end
    ui.styles = getStyles;
    
    % Update the style list.
    updateStyleLists(ui);
    if ~ishghandle(fig), return; end
    ui.active = true;
    setui(fig,ui);
  end

% Save a new style.
function doSave(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    name = char(getText(ui.savetext));
    if ~isempty(name)
      hgexport('writestyle',ui.style,name);
      ui.styles = getStyles;
      ui.active = false;
      clearDirty(ui);
      updateStyleLists(ui);
      drawnow;
      if ~ishghandle(fig), return; end
    end
    ui.active = true;
    setui(fig,ui);
  end

% We've either created a new style, or deleted an old style,
% so we have to update the style list.
function updateStyleLists(ui)
  awtinvoke(ui.selectstylebutton,'setModel(Ljavax/swing/ComboBoxModel;)',...
  	  getStyleComboBoxModel(ui.styles));
  styles = ui.styles;
  styles(strcmp(xdefault,styles)) = [];
  styles(strcmp('PowerPoint',styles)) = [];
  styles(strcmp('MSWord',styles)) = [];
  enableDelete = ~isempty(styles);
  if isempty(styles), styles = {' '}; end
  awtinvoke(ui.deletestylelist,'setModel(Ljavax/swing/ComboBoxModel;)',...
  	  javax.swing.DefaultComboBoxModel(styles));
  awtinvoke(ui.deletebutton,'setEnabled(Z)',enableDelete);

% Hit the OK button, save and make the dialog invisible.
function doOK(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  ui.active = false;
  if ishghandle(ui.figure)
    drawnow;
    if ~ishghandle(fig), return; end
    setappdata(ui.figure,'Exportsetup',ui.style) 
  end
  setui(fig,ui);
  awtinvoke(ui.win,'setVisible(Z)',false);

% Really close the dialog.
function doCloseForce(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  
  % Do not force close if the Visible Property is being reset to 'on'. 
  if (useOriginalHGPrinting(fig))
      if (strcmpi(eventData.Type,'PropertyPostSet') && strcmpi( eventData.Source.Name,'Visible'))
          if (strcmpi(get(fig,'Visible'),'on'))
              return;
          end
      end
  else % ~useOriginalHGPrinting(fig)
      if (strcmpi(eventData.EventName,'PostSet') && strcmpi( eventData.Source.Name,'Visible'))
          if (strcmpi(get(fig,'Visible'),'on'))
              return;
          end
      end
  end  
  
  ui = getui(fig);
  
  % Remove listeners from figure (g556668).
  cellfun(@delete, ui.listeners);
  javaMethodEDT('dispose', ui.win);
  ui.active = false;

% Cleanup on hitting "Cancel"
function doCancel(hSrc, eventData,fig)
  % If there's no figure, leave.
  if ~ishghandle(fig), return; end
  
  % Get the ui, remove the listener from the figure,
  % set the ui to inactive.
  ui = getui(fig);
  ui.active = false;
  setui(fig,ui);
  
  % Restore the old state since we are cancelling, make it
  % like we never touched the figure.
  doRestore(hSrc,eventData,fig);
  
  %Dispose of the window, set the ui to empty.
  awtinvoke(ui.win,'dispose');
  drawnow;
  if ~ishghandle(fig), return; end
  
  % Remove listeners from figure (g556668).
  cellfun(@delete, ui.listeners);
  setui(fig,[]);

% Invoke help.
function doHelp(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  mapfile = [docroot '/techdoc/creating_plots/creating_plots.map'];
  topic = 'howto_export';
  helpview(mapfile, topic);

% Width value changed.
function widthChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    newval = char(getSelectedItem(ui.widthtext));
    if isempty(newval) || strcmp(newval,xauto)
      newval = 'auto';
    end
    if ~isequal(ui.style.Width,newval)
      ui.widthitems = updateEditableComboBox(newval,ui.widthitems,...
                                             ui.widthtext,false);
      ui.style.Width = newval;
      setDirty(ui);
    end
  end

% Height value changed.
function heightChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    newval = char(getSelectedItem(ui.heighttext));
    if isempty(newval)
      newval = 'auto';
    end
    if ~isequal(ui.style.Height,newval)
      ui.heightitems = updateEditableComboBox(newval,ui.heightitems,...
                                              ui.heighttext,false);
      ui.style.Height = newval;
      setDirty(ui);
    end
  end

% Units value changed.
function unitsChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    units = getUnitsVals;
    ui.style.Units = units{getSelectedIndex(ui.unitsbutton)+1};
    setDirty(ui);
  end

% "Expand axes to fill figure" checkbox changed.
function boundsChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if isSelected(ui.boundsbutton)
      ui.style.Bounds = 'tight';
    else
      ui.style.Bounds = 'loose';
    end
    setDirty(ui);
  end

% Colorspace value changed.
function colorChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    [colors, ~] = getColorVals;
    ui.style.Color = colors{getSelectedIndex(ui.colorbutton)+1};
    setDirty(ui);  
  end

% Custom color value changed.
function backcolorChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    ui.style.Background = char(getText(ui.backcolortext));
    setDirty(ui);
  end

% Custom color checkbox changed.
function backcolorcustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Change the custom color text field appropriately (blank or the color).
    if ~isSelected(ui.backcolorcustombutton)
      ui.style.Background = '';
    else
      ui.style.Background = char(getText(ui.backcolortext));
    end
    setDirty(ui);
  end

% Renderer value changed.
function rendererChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    [rends, ~] = getRendererVals;
    ui.style.Renderer = rends{getSelectedIndex(ui.rendererbutton)+1};
    awtinvoke(ui.rendercustombutton,'setSelected(Z)',true);
    setDirty(ui); 
  end

% Renderer checkbox changed.
function rendercustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Change the renderer combobox appropriately ("auto" if not checked).
    if ~isSelected(ui.rendercustombutton)
      ui.style.Renderer = 'auto';
    else
      [rends,~] = getRendererVals; 
      ui.style.Renderer = rends{getSelectedIndex(ui.rendererbutton)+1};
    end
    setDirty(ui);
  end

% Resolution value changed.
function resChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    newvalstr = char(getSelectedItem(ui.restext));
    newval = newvalstr;
    
    % No value, set to "auto"
    if isempty(newvalstr)
      newval = 'auto';
    end
    
    % If "screen", set index to 0 as screen is the first
    % value in the combobox.
    if strcmp(newvalstr,xscreen)
      newval = 0;
    elseif ~strcmp(newvalstr,'auto')
      try
        newval = str2double(newvalstr);
      catch ex
        return; % don't set values if they are illegal
      end
    end
    
    if ~isequal(ui.style.Resolution,newval)
      ui.resitems = updateEditableComboBox(newvalstr,ui.resitems,ui.restext,false);
      ui.style.Resolution = newval;
      setDirty(ui);
    end
  end

% "Keep axis limits" checkbox changed.
function lockChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if isSelected(ui.lockbutton)
      ui.style.LockAxes = 'on';
    else
      ui.style.LockAxes = 'off';
    end
    setDirty(ui);
  end

% "Show uicontrols" checkbox changed.
function showuiChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if isSelected(ui.showuibutton)
      ui.style.ShowUI = 'on';
    else
      ui.style.ShowUI = 'off';
    end
    setDirty(ui);
  end

% "Custom size" font checkbox changed.
function fontmodecustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Check the appropriate radio button.
    if ~isSelected(ui.fontmodecustom)
      ui.style.FontMode = 'none';
    elseif isSelected(ui.fontmodescale)
      ui.style.FontMode = 'scaled';
    else
      ui.style.FontMode = 'fixed';
    end
    setDirty(ui);
  end
  
% Scale radio button changed
function fontmodescaleChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % If selected, check off the checkbox too.
    if isSelected(ui.fontmodescale)
      awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
      ui.style.FontMode = 'scaled';
    end
    setDirty(ui);
  end

% Font value changed.
function fontscaleChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Keep the buttons in sync.
    ui.style.ScaledFontSize = char(getText(ui.fontscale));
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    awtinvoke(ui.fontmodescale,'setSelected(Z)',true);
    ui.style.FontMode = 'scaled';
    setDirty(ui);
  end

% Minimum value changed.
function fontminChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Keep the buttons in sync.
    ui.style.FontSizeMin = str2double(getText(ui.fontmin));
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    awtinvoke(ui.fontmodescale,'setSelected(Z)',true);
    ui.style.FontMode = 'scaled';
    setDirty(ui);
  end

% Fixed font value changed.
function fontfixChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Keep the buttons in sync.
    ui.style.FixedFontSize = str2double(getText(ui.fontfix));
    awtinvoke(ui.fontmodecustom,'setSelected(Z)',true);
    awtinvoke(ui.fontmodefix,'setSelected(Z)',true);
    ui.style.FontMode = 'fixed';
    setDirty(ui);
  end

% Font name value changed.
function fontnameChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    ind = getSelectedIndex(ui.fontnametext);
    ui.style.FontName = ui.fontlist{ind+1};
    awtinvoke(ui.fontnamecustom,'setSelected(Z)',true);
    setDirty(ui);
  end
  
% Font name checkbox changed.
function fontnamecustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if ~isSelected(ui.fontnamecustom)
      ui.style.FontName = 'auto';
    end
    setDirty(ui);
  end

% Font weight value changed.
function fontweightcustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if ~isSelected(ui.fontweightcustom)
      ui.style.FontWeight = 'auto';
    end
    setDirty(ui);
  end

% Font weight checkbox changed.
function weightChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    vals = getWeightVals;
    ui.style.FontWeight = vals{getSelectedIndex(ui.weightbutton)+1};
    awtinvoke(ui.fontweightcustom,'setSelected(Z)',true);
    setDirty(ui);
  end

% Font angle value changed.
function fontanglecustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if ~isSelected(ui.fontanglecustom)
      ui.style.FontAngle = 'auto';
    end
    setDirty(ui);
  end

% Font angle checkbox changed.
function angleChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    vals = getAngleVals;
    ui.style.FontAngle = vals{getSelectedIndex(ui.anglebutton)+1};
    awtinvoke(ui.fontanglecustom,'setSelected(Z)',true);
    setDirty(ui);
  end

% Custom width checkbox changed.
function linemodecustomChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if ~isSelected(ui.linemodecustom)
      ui.style.LineMode = 'none';
    elseif isSelected(ui.linemodescale)
      ui.style.LineMode = 'scaled';
    else
      ui.style.LineMode = 'fixed';
      %Force this radiobutton to be checked, if it is not
      if ~isSelected(ui.linemodefix)
        awtinvoke(ui.linemodefix,'setSelected(Z)',true);
      end
    end
    setDirty(ui);
  end

% Scale radiobutton changed.
function linemodescaleChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if isSelected(ui.linemodescale)
      awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
      ui.style.LineMode = 'scaled';
    end
    setDirty(ui);
  end

% Fixed radiobutton changed.
function linemodefixChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if isSelected(ui.linemodefix)
      awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
      ui.style.LineMode = 'fixed';
    end
    setDirty(ui);
  end

% Scale value changed.
function linescaleChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Keep the buttons in sync.
    ui.style.ScaledLineWidth = char(getText(ui.linescale));
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    awtinvoke(ui.linemodescale,'setSelected(Z)',true);
    ui.style.LineMode = 'scaled';
    setDirty(ui);
  end

% Minimum value changed.
function lineminChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Keep the buttons in sync.
    ui.style.LineWidthMin = str2double(getText(ui.linemin));
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    awtinvoke(ui.linemodescale,'setSelected(Z)',true);
    ui.style.LineMode = 'scaled';
    setDirty(ui); 
  end

% Fixed value changed.
function linefixChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    % Keep the buttons in sync.
    ui.style.FixedLineWidth = str2double(getText(ui.linefix));
    awtinvoke(ui.linemodecustom,'setSelected(Z)',true);
    awtinvoke(ui.linemodefix,'setSelected(Z)',true);
    ui.style.LineMode = 'fixed';
    setDirty(ui);
  end

% "Convert solid lines to cycle through line styles" checkbox changed.
function styleChanged(hSrc, eventData,fig) %#ok<INUSL>
  if ~ishghandle(fig), return; end
  ui = getui(fig);
  if ui.active
    if isSelected(ui.stylebutton)
      ui.style.LineStyleMap = 'bw';
    else
      ui.style.LineStyleMap = 'none';
    end
    setDirty(ui);
  end

%-------------------------  Helper Subfunctions  ----------------------
% Returns Size Units values.
function [out,strs] = getUnitsVals
  out = {'inches','centimeters','points'};  
  strs =  {getString(message('MATLAB:exportsetupdlg:InchesDropdown')),...
      getString(message('MATLAB:exportsetupdlg:CentimetersDropdown')),...
      getString(message('MATLAB:exportsetupdlg:PointsDropdown'))};

% Returns Rendering Colorspace values.
function [out,strs] = getColorVals
  out = {'bw','gray','rgb','cmyk'};
  strs = {getString(message('MATLAB:exportsetupdlg:BlackAndWhiteDropdown')),getString(message('MATLAB:exportsetupdlg:GrayscaleDropdown')),getString(message('MATLAB:exportsetupdlg:RGBColorDropdown')),getString(message('MATLAB:exportsetupdlg:CMYKColorDropdown'))};

% Returns Rendering Custom Renderer values.
function [out,strs] = getRendererVals
  out = {'painters','opengl'};
  strs = {getString(message('MATLAB:exportsetupdlg:PaintersDropdown')),...
        getString(message('MATLAB:exportsetupdlg:OpenGLDropdown'))};

% Returns Fonts Weight values.
function [out,strs] = getWeightVals
  out = {'normal', 'bold'};
  strs =  {getString(message('MATLAB:exportsetupdlg:NormalDropdown')),...
      getString(message('MATLAB:exportsetupdlg:BoldDropdown'))};

% Returns Fonts Angle values.
function [out,strs] = getAngleVals
  out = {'normal','italic','oblique'}; 
   strs =  {getString(message('MATLAB:exportsetupdlg:NormalDropdown')),...
      getString(message('MATLAB:exportsetupdlg:ItalicDropdown')),...
      getString(message('MATLAB:exportsetupdlg:ObliqueDropdown'))};

% Returns the four strings for the four different panels.
function [out,strs] = getTabs
  out = {'Size','Rendering','Fonts','Lines'};
      strs =  {getString(message('MATLAB:exportsetupdlg:SizeDropdown')),...
      getString(message('MATLAB:exportsetupdlg:RenderingDropdown')),...
      getString(message('MATLAB:exportsetupdlg:FontsDropdown')),...
      getString(message('MATLAB:exportsetupdlg:LinesDropdown'))};

% Initialize a combobox.
function items = updateEditableComboBox(str,items,combobox,select)
  % If empty or auto, set to auto.
  if isempty(str) || strcmp(str,'auto'), str = xauto; end
  
  % If no selection, set to first item.
  ind = find(strcmpi(str,items));
  if isempty(ind)
    if strcmp(str,'0'), str = xscreen; end % for resolution = 0
    items = {str, items{:}}; 
    awtinvoke(combobox,'insertItemAt(Ljava/lang/Object;I)',...
              java.lang.String(str),0);
    ind = 1;
  end
  
  % If selected, set the selected index.
  if select
    awtinvoke(combobox,'setSelectedIndex(I)',ind-1);
  end

% Return the directory for export setup fro the preferences.
function path = getStyleDir
  path = fullfile(prefdir(0),'ExportSetup');

% Initialize the default styles.
function initStandardStyles(path)

  % Initialize Word style.
  wordfile = fullfile(path,'MSWord.txt');
  if ~exist(wordfile,'file')
    word = hgexport('factorystyle');
    hgexport('writestyle',word,'MSWord');
  end
  
  % Initialize PowerPoint style.
  pptfile = fullfile(path,'PowerPoint.txt');
  if ~exist(pptfile,'file')
    ppt = hgexport('factorystyle');
    ppt.FontWeight = 'bold';
    ppt.FontMode = 'scaled';
    ppt.ScaledFontSize = '140';
    ppt.LineMode = 'fixed';
    ppt.FixedLineWidth = 2;
    hgexport('writestyle',ppt,'PowerPoint');
  end
  
% Set the dirty flag and set the dynamic property to ui.  
function setDirty(ui)
if ui.active
  ui.dirty = true;
  setui(ui.figure,ui);
end

% Clear the dirty flag and set the dynamic property to ui.
function clearDirty(ui)
  ui.dirty = false;
  setui(ui.figure,ui);

% Add custom styles to the style list.
function styles = getStyles
  % Get the styles in the style directory.
  styledir = getStyleDir;
  files = dir(styledir);
  files = files([files.isdir] == 0);
  styles = {files.name};
  isstyle = false(length(styles),1);
  
  % Check to see if there are any styles (must end in ".txt").
  for k=1:length(styles)
    if regexp(styles{k},'\.txt$')
      isstyle(k) = true;
      styles{k} = styles{k}(1:end-4);
    end
  end
  
  % Go through the list and add PowerPoint and MSWord if
  % they aren't already there.
  styles = styles(isstyle);
  if ~any(strcmpi(styles,xdefault))
    styles = {xdefault,styles{:}};   %#ok<*CCAT>
  end
  if ~any(strcmp(styles,'PowerPoint'))
    styles = {styles{:}, 'PowerPoint'};
  end
  if ~any(strcmp(styles,'MSWord'))
    styles = {styles{:}, 'MSWord'};
  end

% Look for the dynamic property 'ExportsetupWindow';
% if it exists, return its value, otherwise set it to empty.
function ui = getui(fig)
  % If no figure, then return.
  if ~ishghandle(fig), return; end
  
  % Set ui to empty.
  ui = [];
  
  % If the figure has the dynamic property, set ui to its value.  
  if isprop(handle(fig),'ExportsetupWindow')
    ui = get(handle(fig),'ExportsetupWindow');
  end

% Creates the dynamic property 'ExportsetupWindow' if it
% doesn't exist, then sets the value to ui.
function setui(fig,ui)
  % If no figure, then return.
  if ~ishghandle(fig), return; end
  
  % Get the handle to the figure
  hfig = handle(fig);
 
  % Set the dynamic property to ui.
  set(hfig,'ExportsetupWindow',ui);

function setcallback(java_obj, callback, value)
set(handle(java_obj,'callbackproperties'),callback,value);

% I18N support helpers

% Returns translated 'auto'.
function out = xauto
  out = getString(message('MATLAB:exportsetupdlg:AutoText'));

% Returns translated 'screen'.
function out = xscreen
  out = getString(message('MATLAB:exportsetupdlg:ScreenText'));

% Returns translated "default" style
function out = xdefault
  out = getString(message('MATLAB:exportsetupdlg:DefaultText'));
  
