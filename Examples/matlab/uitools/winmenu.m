function out = winmenu(in)
% This function is undocumented and will change in a future release

%WINMENU Create submenu for "Window" menu item.
%  WINMENU(H) constructs a submenu under the menu specified by H.
%
%  WINMENU(F) looks for the uimenu child of figure F with the Tag
%  'winmenu' and initializes it.
%
%  cb = WINMENU('callback') returns the proper callback string for the
%  menu item under which the submenu is to be constructed (for
%  backwards compatibility).  The callback is always
%  'winmenu(gcbo)'.
%
%  Example:
%
%  fig_handle = figure;
%  uimenu(fig_handle, 'Label', 'Window', ...
%      'Callback', winmenu('callback'), 'Tag', 'winmenu');
%  winmenu(fig_handle);  % Initialize the submenu


%  WINMENU constructs a submenu under the "Window" menu item
%  of the current figure.  The submenu can then be used to
%  change the current figure.  To use WINMENU, the "Window"
%  menu item must have its 'Tag' property set to 'winmenu'.
%
%  WINMENU(FIG) constructs the "Window" submenu for figure
%  FIG.
%
%  WINMENU('callback') returns the callback string to use in
%  the top-level uimenu item.
%

%  Steven L. Eddins, 6 June 1994
%  Copyright 1984-2017 The MathWorks, Inc.

% We can be called with 0 or 1 input args:
narginchk(0, 1);

if nargin > 0
    in = convertStringsToChars(in);
end

if (nargout > 0)
    out = []; % preinitialize out
end

if(nargin == 1)
    if ischar(in)
        %
        % The only legal string arg is 'callback'
        %
        if strcmp(in, 'callback')
            out = 'winmenu(gcbo)';
        elseif strcmp(in,'morewindowsdlg')
            morewindowsdlg;
        elseif strcmp(in,'morewindowscb')
            morewindowscb;
        else
            error(message('MATLAB:winmenu:UnrecognizedStringArg', in));
        end
        return;

        %elseif length(in) == 1 && ishghandle(in)
    elseif any(ishghandle(in))
        %
        % The only other legal arg is a single figure or uimenu handle:
        %
        t = get(in,'Type');
        if(strcmp(t,'uimenu'))
            h = in;
        elseif(strcmp(t,'figure'))
            h = findwinmenu(in);
        else
            error(message('MATLAB:winmenu:InvalidHandleArg'));
        end
    else
        error(message('MATLAB:winmenu:InvalidInputArg'));
    end
else
    h = findwinmenu(gcf);
end

% By this point, we must have the handle to a uimenu item:
if ~isscalar(h) || ~ishghandle(h,'uimenu') 
    error(message('MATLAB:winmenu:WindowMenuNotFound'));
end

% The strategy:
%
% 1) there will be no more than 11 items on the window menu,
% allowing us to use the Mnemonics 0 through 9 for windows, plus an
% additional More Windows... item when necessary.  We will reuse
% menus, and whenever fewer than 10 are required, we will hide the
% ones not currently in use.  Let's minimize creation and deletion
% of uimenus during the posting of this submenu!
%
% 2) The command window will always be listed first, with the
% mnemonic 0.
%
% 3) There will be a separator, and then up to nine figures, using
% mnemonics 1 through the number of figures.  A figure will be
% listed on the menu using its titlebar string, which is a function
% of the Numbertitle property, its handle, and its Name property.
% The listing will be in sorted order by titlebar string.
%
% 4) If there are fewer than 9 figures, the remaining slots will
% list Simulink block diagram windows, using the remaining mnemonics
% through 9.  Simulink block diagram windows will be listed by
% their titlebar contents.  There will be a separator between the
% figures and the simulink items.
%
% 5) If there are any windows not listed due to space constraints,
% there will be one more separator, followed by an item labeled
% 'More windows', with the mnemonic 'M'.

% 1) make sure there are 11 items:
menus = allchild(h);
len = length(menus);
need_more_item = 0;
if isempty(menus)
    menus = [];
end
if len > 11
    delete(menus(12:end));
    menus(12:end) = [];
else
    for i=(len+1):11
        menus(i) = uimenu(h);
    end
end

menus = flipud(menus);
set(menus,'HandleVisibility','off','Serializable','off',...
    'Separator','off','Visible','on');


% 2) list the command window
first_windowmenu_added = false;
if (~isdeployed)
    set(menus(1),'Label',getString(message('MATLAB:uistring:winmenu:MATLABCommandWindow')),...
        'Callback', @showCommandWindow);
    first_windowmenu_added = true;
    menus(1) = [];
end

set(menus(end),'Label',getString(message('MATLAB:uistring:winmenu:MoreWindows')),'Separator','on',...
    'Callback','winmenu morewindowsdlg','Tag','figWinMenuMoreWindows');
more_item = menus(end);
menus(end) = [];

len = length(menus);
num_dtmenus = 0;
% 2.5) enumerate the other desktop windows
arrayOfGroupStructs = getDesktopGroups;
for i=1:length(arrayOfGroupStructs)
    desktopOwners = arrayOfGroupStructs(i).owners;
    ownerNames = arrayOfGroupStructs(i).ownerNames;
    
    num_dtmenus = min(length(desktopOwners), len);
    if len < length(desktopOwners)
        need_more_item = 1;
    end
    if num_dtmenus
        for i = 1:num_dtmenus
            ownerNames{i} = sprintf('&%d %s',i,constrainName(char(ownerNames{i})));
        end
        %ToDo: is calling activate thread safe for DT clients?
        set(menus(1:(num_dtmenus)),{'Label'},ownerNames(1:num_dtmenus)',...
            'Callback','activate(get(gcbo,''userdata''));',...
            {'UserData'},desktopOwners(1:num_dtmenus)');
        if (first_windowmenu_added)
            set(menus(1),'Separator','on');
        else
            first_windowmenu_added = true;
        end
        menus(1:num_dtmenus) = [];
        len = length(menus);
    end
end



% 3) enumerate the figures
[figs, fignames] = getfigtitles;

num_figmenus = min(length(figs), len);
if num_figmenus < length(figs)
    need_more_item = 1;
end
if num_figmenus
    fighandles = cell(1,num_figmenus);
    for i = 1:num_figmenus
        fignames{i} = sprintf('&%d %s',i+num_dtmenus,constrainName(char(fignames{i})));
        fighandles{i} = figs(i);
    end
    set(menus(1:(num_figmenus)),{'Label'},fignames(1:num_figmenus)',...
        'Callback','figure(get(gcbo,''userdata''))',...
        {'UserData'},fighandles');
    
    if (first_windowmenu_added)
        set(menus(1),'Separator','on');
    else
        first_windowmenu_added = true; %#ok<NASGU>
    end
    menus(1:num_figmenus) = [];
    %len = length(menus);
end

%********************* Begin Simulink Model Support *********************
% This piece of code is commented out to remove the performance hit of
% possibly loading Simulink.

% % 4) enumerate the models:
% models = getmodeltitles;
% if len < length(models)
%   need_more_item = 1;
% end
%
% num_modelmenus = min(length(models), len);
% if num_modelmenus
%   models = sort(models);
%   for i=1:num_modelmenus
%     modelnames{i} = sprintf('&%d %s',i+num_dtmenus+num_figmenus, constrainName(models{i}));
%   end
%  set(menus(1:num_modelmenus),{'label'},modelnames(1:num_modelmenus)',...
%      'callback','open_system(get(gcbo,''userdata''))',...
%      {'userdata'},models(1:num_modelmenus));
%   if (~isdeployed)
%     set(menus(1),'separator','on');
%   end
%   menus(1:num_modelmenus) = [];
%   len = length(menus);
% end
%********************* End Simulink Model Support *********************

set(menus,'Visible','off');
if ~need_more_item
    set(more_item,'Visible','off');
end

drawnow
%%% end main winmenu function %%%


function h = findwinmenu(fig)
%
% Look for the specially tagged menu:
% INPUT ARG MUST BE A FIGURE
%
if ~strcmp(get(fig,'Type'),'figure')
    error(message('MATLAB:winmenu:RequiresFigureHandle'));
end
h = findall(fig,'type','uimenu','tag','winmenu');
%%% end function findwinmenu



function  arrayOfGroupStructs = getDesktopGroups

% NOTE: This function uses undocumented java objects whose behavior will
%       change in future releases.  When using this function as an example,
%       use java objects from the java.awt or javax.swing packages to ensure
%       forward compatibility.
arrayOfStructs = repmat(struct('owners',[],'ownerNames',[]),1,0);
if usejava('jvm')
    reg = com.mathworks.widgets.desk.DTWindowRegistry.getInstance;
    owners = reg.getActivators.toArray;
    list = cell(length(owners),3);
    for i=1:length(owners)
        list(i,:) = {char(owners(i).getGroupName)  owners(i) char(owners(i).getShortTitle)};
    end
    groupnamelist = unique(list(:,1));
    arrayOfStructs = repmat(struct('owners',[],'ownerNames',[]),1,length(groupnamelist));
    for j=1:length(groupnamelist)
        for i=1:size(list,1)
            if (strcmpi(list(i,1),groupnamelist(j)) && ~strcmpi(groupnamelist(j),'Figures') && ~strcmpi(groupnamelist(j),'Simulink'))
                tempOwner= list(i,2);
                arrayOfStructs(j).owners{end+1} = tempOwner{1};
                tempName = list(i,3);
                arrayOfStructs(j).ownerNames{end+1} = tempName{1};
            end
        end
    end
end
arrayOfGroupStructs = arrayOfStructs;
%%% end function getDesktopTitles


function [figs, titles] = getfigtitles
%
% returns titles of all passed-in figures in a cell array
%

figs = findobj(allchild(0),'flat','type','figure','visible','on');
titles = {};
j = 1;
while j<=length(figs)
  name = get(figs(j),'Name');
  
  % store the last warning thrown
  [ lastWarnMsg, lastWarnId ] = lastwarn;

  % disable the warning when using the 'JavaFrame' property
  % this is a temporary solution
  oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
  jf = get(figs(j),'JavaFrame');
  warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

  % restore the last warning thrown
  lastwarn(lastWarnMsg, lastWarnId);
  
  if (~isempty(jf) && ...
      strcmpi(jf.getGroupName,'Figures'))
      if ~isempty(name)
          name = strrep(name,newline,' ');
          name = strrep(name,char(13),' ');
      end
      t = '';
      if strcmp(get(figs(j),'NumberTitle'),'on')
          t = sprintf('Figure %.8g',double(figs(j)));
          if ~isempty(name)
              t = [t, ': ']; %#ok<AGROW>
          end
      end
      titles{j} = [t, name];
  else
      figs(j) = [];
      titles{j} = [];
      j=j-1;
  end
  j=j+1;
end

%Remove entries in titles which are empty
i = cellfun('isempty', titles);
i = ~i;
titles = titles(i);

[titles, order] = sort(titles);
figs = figs(order);

%%% end function getfigtitle

%********************* Begin Simulink Model Support *********************
% This piece of code is commented out to remove the performance hit of
% possibly loading Simulink.

% function out = getmodeltitles
% %
% % return titles of all models:
% %
%
% out = {};
%
% % check to see whether simulink is in use in this MATLAB session
% tic
% inuse = license('inuse');
% if ~isempty(inuse) && any(strcmp({inuse.feature},'simulink'))
% 	out = find_system('open','on');
% end
% toc
%
% % replace newlines and carriage returns in multiline titles with
% % spaces:
% out = strrep(out,char(10),' ');
% out = strrep(out,char(13),' ');
%
% %%% end function getmodeltitles

%********************* End Simulink Model Support ***********************

function morewindowsdlg
%
% Construct a platform-independent modal dialog containing a
% listbox and an OK and CANCEL button, for browsing the list of all
% figures
%
% make the dialog 200 x 300 pixels, to the left of the figure whose
% window menu invoked it, but make sure to keep it on the screen:
figpos = get(gcbf,'Position');
figtop = figpos(2) + figpos(4);
dlgw = 200;
dlgh = 300;
dlgl = max(figpos(1) - dlgw - 10, 0);
dlgb = max(figtop - dlgh, 0);

arrayOfGroupStructs = getDesktopGroups;
owners = arrayOfGroupStructs.owners;
ownernames = arrayOfGroupStructs.ownerNames;

[figs, fignames] = getfigtitles;
% exclude = find(figs == f);
% figs(exclude) = [];
% fignames(exclude) = [];

n_dts = length(owners);
n_figs = length(figs);
ud = cell(n_figs +n_dts,2);
for i=1:n_dts
    ud{i,1}='activate';
    ud{i,2}=owners{i};
end
for i=1:n_figs
    ud{i+n_dts,1} = 'figure';
    ud{i+n_dts,2} = figs(i);
end


%********************* Begin Simulink Model Support *********************
% This piece of code is commented out to remove the performance hit of
% possibly loading Simulink.

%modelnames = getmodeltitles;
%n_models = length(modelnames);
%for i = 1:n_models
%  ud{i+n_dts+n_figs, 1} = 'open_system';
%  ud{i+n_dts+n_figs, 2} = modelnames{i};
%end

%str =  [ownernames fignames modelnames'];

%********************* End Simulink Model Support ***********************

str =  [ownernames fignames];

f = figure('NumberTitle','off',...
    'Name',getString(message('MATLAB:uistring:winmenu:ChooseAWindow')),...
    'IntegerHandle','off',...
    'WindowStyle','modal',...
    'Resize','off',...
    'Color',get(0,'FactoryUicontrolBackgroundColor'),...
    'Tag','figChooseAWindow',...
    'Position',[dlgl, dlgb, dlgw, dlgh]); %#ok<NASGU>

l = uicontrol('Style','listbox','Position',[10 50 180 240]);

set(l,'String',str','UserData',ud,'Callback',...
    'winmenu morewindowscb');

uicontrol('String',getString(message('MATLAB:uistring:winmenu:OK')),'Position',[10 10 85 30],...
    'Callback','winmenu morewindowscb','UserData',l,'Tag','OKButton');
uicontrol('String',getString(message('MATLAB:uistring:winmenu:Cancel')),'Position',[105 10 85 30],...
    'Callback','delete(gcbf)','Tag','CancelButton');
%%% end function morewindowsdlg

function morewindowscb
%
% Select the window, and close the dialog.
%
l = gcbo;
l_type = get(l,'Style');

switch l_type
    case 'listbox'
        if ~strcmp(get(gcbf,'SelectionType'),'open')
            return;
        end
    case 'pushbutton'
        l = get(l,'UserData');
    otherwise
        error(message('MATLAB:winmenu:UnexpectedObjType', l_type));
end

ud=get(l,'UserData');
val=get(l,'Value');

% delete the modal dialog figure BEFORE raising the selected model or
% figure, because on some platforms (PC) some window types (Models)
% will not be raised successfully while a modal window is up. -DTP
delete(gcbf);

% now call the raise command stored in userdata for this type of
% window
feval(ud{val,1},ud{val,2});


function showCommandWindow(~, ~) 
commandwindow();

function nameOut = constrainName(nameIn)

if length(nameIn) > 32
    nameOut = strcat(nameIn(1:30), '...');
else
    nameOut = nameIn;
end
