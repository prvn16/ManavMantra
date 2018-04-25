function odeexamples(section)
%ODEEXAMPLES  Browse ODE/DAE/IDE/BVP/PDE examples.
%   ODEEXAMPLES with no input arguments starts the browser and displays
%   the list of examples of solving ordinary differential equations, ODEs.
%   ODEEXAMPLES(SECTION) with SECTION = 'ode', 'dae', 'ide', 'dde', 'bvp',
%   or 'pde', starts the browser and displays the list of examples for
%   the particular class of problems.

%   Copyright 1984-2016 The MathWorks, Inc.

if (nargin < 1) || (~ischar(section) && ~(isstring(section) && isscalar(section)))
   section = 'ode';   % default to 'ode'
end

switch lower(section)
   case 'ode'
      startSection = 1;
   case 'dae'
      startSection = 2;
   case 'ide'          % fully implicit Differential Equations
      startSection = 3;
   case 'dde'
      startSection = 4;
   case 'bvp'
      startSection = 5;
   case 'pde'
      startSection = 6;
   otherwise
      startSection = 1;  % default to 'ode'
end

category_names = {
   getString(message('MATLAB:demos:odeexamples:LabelODE'))
   getString(message('MATLAB:demos:odeexamples:LabelDAE'))
   getString(message('MATLAB:demos:odeexamples:LabelIDE'))
   getString(message('MATLAB:demos:odeexamples:LabelDDE'))
   getString(message('MATLAB:demos:odeexamples:LabelBVP'))
   getString(message('MATLAB:demos:odeexamples:LabelPDE'))};

odeitems = {
   getString(message('MATLAB:demos:odeexamples:LabelBallode'))
   getString(message('MATLAB:demos:odeexamples:LabelBatonode'))
   getString(message('MATLAB:demos:odeexamples:LabelBrussode'))
   getString(message('MATLAB:demos:odeexamples:LabelBurgersode'))
   getString(message('MATLAB:demos:odeexamples:LabelFem1ode'))
   getString(message('MATLAB:demos:odeexamples:LabelFem2ode'))
   getString(message('MATLAB:demos:odeexamples:LabelHb1ode'))
   getString(message('MATLAB:demos:odeexamples:LabelKneeode'))
   getString(message('MATLAB:demos:odeexamples:LabelOrbitode'))
   getString(message('MATLAB:demos:odeexamples:LabelRigidode'))
   getString(message('MATLAB:demos:odeexamples:LabelVdpode')) };
odedemos = odeitems;
for i = 1:length(odedemos)
   odedemos{i} = strtok(odedemos{i});
end

daeitems = {
   getString(message('MATLAB:demos:odeexamples:LabelAmp1dae'))
   getString(message('MATLAB:demos:odeexamples:LabelHb1daew'))};
daedemos = daeitems;
for i = 1:length(daeitems)
   daedemos{i} = strtok(daeitems{i});
end

ideitems = {
   getString(message('MATLAB:demos:odeexamples:LabelIburgersode'))
   getString(message('MATLAB:demos:odeexamples:LabelIhb1dae'))};
idedemos = daeitems;
for i = 1:length(ideitems)
   idedemos{i} = strtok(ideitems{i});
end

ddeitems = {
   getString(message('MATLAB:demos:odeexamples:LabelDdex1'))
   getString(message('MATLAB:demos:odeexamples:LabelDdex2'))
   getString(message('MATLAB:demos:odeexamples:LabelDdex3'))
   getString(message('MATLAB:demos:odeexamples:LabelDdex4'))
   getString(message('MATLAB:demos:odeexamples:LabelDdex5'))};
ddedemos = daeitems;
for i = 1:length(ddeitems)
   ddedemos{i} = strtok(ddeitems{i});
end

bvpitems = {
   getString(message('MATLAB:demos:odeexamples:LabelEmdenbvp'))
   getString(message('MATLAB:demos:odeexamples:LabelEmdenbvp5c'))
   getString(message('MATLAB:demos:odeexamples:LabelFsbvp'))
   getString(message('MATLAB:demos:odeexamples:LabelFsbvp5C'))
   getString(message('MATLAB:demos:odeexamples:LabelMat4bvp'))
   getString(message('MATLAB:demos:odeexamples:LabelMat4bvp5c'))
   getString(message('MATLAB:demos:odeexamples:LabelRcbvp'))
   getString(message('MATLAB:demos:odeexamples:LabelShockbvp'))
   getString(message('MATLAB:demos:odeexamples:LabelShockbvp5c'))
   getString(message('MATLAB:demos:odeexamples:LabelThreebvp'))
   getString(message('MATLAB:demos:odeexamples:LabelThreebvp5c'))
   getString(message('MATLAB:demos:odeexamples:LabelTwobvp'))};
bvpdemos = bvpitems;
for i = 1:length(bvpitems)
   bvpdemos{i} = strtok(bvpitems{i});
end

pdeitems = {
   getString(message('MATLAB:demos:odeexamples:LabelPdex1'))
   getString(message('MATLAB:demos:odeexamples:LabelPdex2'))
   getString(message('MATLAB:demos:odeexamples:LabelPdex3'))
   getString(message('MATLAB:demos:odeexamples:LabelPdex4'))
   getString(message('MATLAB:demos:odeexamples:LabelPdex5'))};
pdedemos = pdeitems;
for i = 1:length(pdeitems)
   pdedemos{i} = strtok(pdeitems{i});
end

category_items = {odeitems,daeitems,ideitems,ddeitems,bvpitems,pdeitems};
category_demos = {odedemos,daedemos,idedemos,ddedemos,bvpdemos,pdedemos};

selectdemo(category_names,category_items,category_demos,startSection);

% --------------------------------------------------------------------------

function selectdemo(category_names,category_items,category_demos,startSection)

figname = getString(message('MATLAB:demos:odeexamples:TitleDifferentialEquationsExamples'));
examplestring = getString(message('MATLAB:demos:odeexamples:LabelExamplesOf'));
viewstring = getString(message('MATLAB:demos:odeexamples:LabelViewCode'));
runstring = getString(message('MATLAB:demos:odeexamples:LabelRunExample'));
closestring = getString(message('MATLAB:demos:odeexamples:LabelClose'));

fontname = 'Monospaced';
fontsize = 11;

fig = figure('Name',figname, ...
   'Resize','on', ...
   'Menubar','none', ...
   'CloseRequestFcn',@doClose, ...
   'NumberTitle','off', ...
   'Visible','off', ...
   'NextPlot','add',...
   'IntegerHandle','off',...
   'HandleVisibility','on');

dp = fig.Position;
fW = 1.1*dp(3);   % width
fH = 0.75*dp(4);  % height
fp = [dp(1) dp(2)+dp(4)-fH fW fH];   % fix upper left corner
fig.Position = fp;
fig.Visible = 'on';

exampletitle = uicontrol('Style','text',...
   'Units','normal',...
   'Position',[0.02 0.825 0.20 0.1],...
   'BackgroundColor',fig.Color,...
   'FontName',fontname,...
   'FontSize',fontsize,...
   'HorizontalAlignment','left',...
   'String',examplestring);
exampletitle.Units = 'pixels';

listbox = uicontrol('Style','listbox',...
   'Max',1,...
   'Units','normal',...
   'Position',[0.02 0.33 0.97 0.5],...
   'BackgroundColor','w',...
   'FontName',fontname,...
   'FontSize',fontsize,...
   'String',cellstr(category_items{startSection}));
listbox.Units = 'pixels';

popupmenu = uicontrol('Style','popupmenu',...
   'Max', 1,...
   'Units','normal',...
   'Position',[0.21 0.86 0.51 0.076],...
   'BackgroundColor','w',...
   'FontName',fontname,...
   'FontSize',fontsize,...
   'HorizontalAlignment','left',...
   'String',cellstr(category_names),...
   'Value',startSection,...
   'Callback',{@changeCategory,listbox,category_items});
popupmenu.Units = 'pixels';

view_btn = uicontrol('Style','pushbutton',...
   'String',viewstring,...
   'Units','normal',...
   'Position',[0.21 0.2 0.26 0.1],...
   'Callback',{@doView,popupmenu,listbox,category_demos});
view_btn.Units = 'pixels';

run_btn = uicontrol('Style','pushbutton',...
   'String',runstring,...
   'Units','normal',...
   'Position',[0.53 0.2 0.26 0.1],...
   'Callback',{@doRun,popupmenu,listbox,category_demos});
run_btn.Units = 'pixels'; ...
   
separator =  uicontrol('Style','frame',...
   'Units','normal',...
   'Position',[0.02 0.15 0.96 0.005]);
separator.Units = 'pixels'; ...
   
close_btn = uicontrol('Style','pushbutton',...
   'String',closestring,...
   'Units','normal',...
   'Position',[0.79 0.02 0.19 0.1],...
   'Callback',@doClose);
close_btn.Units = 'pixels';

fig.HandleVisibility = 'off';
fig.ResizeFcn = {@doResize,fp, exampletitle,exampletitle.Position,...
   popupmenu,popupmenu.Position, listbox,listbox.Position,...
   view_btn,view_btn.Position, run_btn,run_btn.Position,...
   separator,separator.Position, close_btn,close_btn.Position};

% --------------------------------------------------------------------------

function doView(view_btn, evd, category, example, demos)
name = demos{category.Value}{example.Value};

name = regexprep(name,'\(.+\)','');   % remove fcn arguments

gg = gcbf;
pointer = gg.Pointer;
gg.Pointer = 'watch';
try
   eval(['edit ',name]);
catch
end
gg.Pointer = pointer;

% --------------------------------------------------------------------------

function doRun(run_btn, evd, category, example, demos)
name = demos{category.Value}{example.Value};

gg = gcbf;
pointer = gg.Pointer;
gg.Pointer = 'watch';
try
   eval(name);
catch
end
gg.Pointer = pointer;

% --------------------------------------------------------------------------

function doClose(close_btn, evd)
delete(gcbf);

% --------------------------------------------------------------------------

function changeCategory(popup, evd, listbox, category_items)
categoryIdx = popup.Value;
items = category_items{categoryIdx};
listbox.String = cellstr(items);
listbox.Value = 1;

% --------------------------------------------------------------------------

function doResize(fig,evd,fp,exampletitle,example_pos,popup,popup_pos,...
   list,list_pos,view_btn,view_pos,run_btn,run_pos,...
   sep,sep_pos,close_btn,close_pos);

np = fig.Position;
dh = np(3) - fp(3);
dv = np(4) - fp(4);

list_pos(3) = list_pos(3) + dh;
list_pos(4) = list_pos(4) + dv;
example_pos(2) = example_pos(2) + dv;
popup_pos(2) = popup_pos(2) + dv;
popup_pos(3) = min(popup_pos(3),np(3)-popup_pos(1));
view_pos(1) = view_pos(1) + dh/2;
run_pos(1) = run_pos(1) + dh/2;
sep_pos(3) = sep_pos(3) + dh;
close_pos(1) = close_pos(1) + dh;

try
   list.Position = list_pos;
   exampletitle.Position = example_pos;
   popup.Position = popup_pos;
   sep.Position = sep_pos;
   close_btn.Position = close_pos;
   view_btn.Position = view_pos;
   run_btn.Position = run_pos;
catch
end
