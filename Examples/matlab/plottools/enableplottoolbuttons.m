function enableplottoolbuttons (fig)
% This undocumented function may be removed in a future release.
  
% Check to see if all the plot tool components are either hidden or 
% showing, and enable/disable the toolbar buttons accordingly.

% Copyright 2006-2014 The MathWorks, Inc.

if isempty(fig) || ~ishandle(fig)
    return;
end

if isappdata(fig, 'UISuspendActive')
    % something's turned them off already -- leave them alone!
    return;
end

jf = javaGetFigureFrame(fig);
if isempty(jf)
    return;
end
groupName = jf.getGroupName;
dt = jf.getDesktop;

onBtn  = uigettool (fig, 'Plottools.PlottoolsOn');
offBtn = uigettool (fig, 'Plottools.PlottoolsOff');

% If this figure is undocked from the group, show the 'on' button.
% Otherwise, proceed.
if strcmpi (get(fig, 'WindowStyle'), 'docked') == 0
    set (onBtn, 'enable', 'on');
    set (offBtn, 'enable', 'off');
    return;
end

fpVisible = isCompVisible ('Figure Palette', groupName, dt);
pbVisible = isCompVisible ('Plot Browser', groupName, dt);
peVisible = isCompVisible ('Property Editor', groupName, dt);
if (fpVisible == false) && ...
   (pbVisible == false) && ...
   (peVisible == false)
     localSetToolbarButtons(groupName,'on')
else
    localSetToolbarButtons(groupName,'off')
end


%% -----------------------------------------------------
function isVisible = isCompVisible (compName, groupName, dt)
comp = dt.getClient (compName, groupName);
if isempty(comp)
    isVisible = false;
    return;
end
isVisible = dt.isClientShowing(comp);

%------------------------------------------------------------------------%
function localSetToolbarButtons(groupName,state)

% Set the state of the Plottools.PlottoolsOn toolbar button for all the
% figures in the specified group and set the Plottools.PlottoolsOff to the
% alternate state
if strcmp(state,'on')
    altstate = 'off';
else
    altstate = 'on';
end
allFigs = findall(groot,'type','figure'); 
for k=1:length(allFigs)
    if strcmp(get(allFigs(k),'WindowStyle'),'docked')
         if strcmp(groupName,char(getGroupName(javaGetFigureFrame(allFigs(k)))))
             onBtn  = uigettool (allFigs(k), 'Plottools.PlottoolsOn');
             offBtn = uigettool (allFigs(k), 'Plottools.PlottoolsOff');
             set (onBtn, 'enable', state);
             set (offBtn, 'enable', altstate );
          end
    end
end
