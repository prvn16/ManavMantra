function lblstr = getDisplayLabel(this)
%GETDISPLAYLABEL Return the label for the Model Explorer
%   OUT = GETDISPLAYLABEL(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

lblstr = '';
if isempty(this.TreeNode); return; end
if(isa(this.TreeNode.daobject, 'DAStudio.Object') || isa(this.TreeNode.daobject, 'Simulink.ModelReference'))
    bae = fxptui.BAExplorer.getBAExplorer;
    hDlg = [];
    if ~isempty(bae)
        hDlg = bae.getDialog;
    end
    try
        lblstr = this.TreeNode.daobject.getDisplayLabel;
        logstr = getlogstr(this, hDlg);
        dtostr = getdtostr(this, hDlg);
        lblstr = getlblstr(lblstr, logstr, dtostr);
    catch e
    end
end
%--------------------------------------------------------------------------
function logstr = getlogstr(this, hDlg)
logstr = '';
activeTab = 0;
if ~isempty(hDlg)
    activeTab = hDlg.getActiveTab('shortcut_editor_tabs');
end
if activeTab == 1
    if(~this.isdominantsystem('MinMaxOverflowLogging'))
        return;
    end
    logvalue = this.MinMaxOverflowLogging;
else
    if(~this.isDominantSystemForSetting('MinMaxOverflowLogging'))
        return;
    end
    logvalue = this.getParameterValue('MinMaxOverflowLogging');
end
    
% Use a switchyard instead of ismember() to improve performance.
switch logvalue
  case 'UseLocalSettings'
    logstr = '';
  case 'MinMaxAndOverflow'
    logstr = 'mmo'; 
  case 'OverflowOnly'
    logstr = 'o'; 
  case 'ForceOff'
    logstr = 'off'; 
  otherwise
    %do nothing;
end

%--------------------------------------------------------------------------
function dtostr = getdtostr(this, hDlg)
dtostr = '';
activeTab = 0;
if ~isempty(hDlg)
    activeTab = hDlg.getActiveTab('shortcut_editor_tabs');
end
if activeTab == 1
    if(~this.isdominantsystem('DataTypeOverride'))
        return;
    end
    dtovalue = this.DataTypeOverride;
else
    if(~this.isDominantSystemForSetting('DataTypeOverride'))
        return;
    end
    dtovalue = this.getParameterValue('DataTypeOverride');
end
% Use a switchyard instead of ismember() to improve performance.
switch dtovalue
  case 'UseLocalSettings'
    dtostr = '';
  case {'ScaledDoubles', 'ScaledDouble'}
    dtostr = 'scl'; 
  case {'TrueDoubles', 'Double'}
    dtostr = 'dbl'; 
  case {'TrueSingles', 'Single'}
    dtostr = 'sgl'; 
  case {'ForceOff', 'Off'}
    dtostr = 'off';
  otherwise
      
    %do nothing;fxpde
end

%--------------------------------------------------------------------------
function lblstr = getlblstr(lblstr, logstr, dtostr)
if(isempty(logstr) && isempty(dtostr))
    return;
end
dash = '';
lblstr = [lblstr ' (' logstr];
if(~isempty(dtostr))
    if(~isempty(logstr))
        dash = '-';
    end
    %append the dto string to the label
    lblstr = [lblstr dash dtostr];
end
lblstr = [lblstr ')'];

% [EOF]

% [EOF]
