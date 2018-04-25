function tabgroup = showcaseBuildTabGroup(mode)
% Build the TabGroup used in the toolstrip.

% Author(s): Rong Chen
% Copyright 2015 The MathWorks, Inc.
import matlab.ui.internal.toolstrip.*
tabgroup = TabGroup();
tab1 = matlab.ui.internal.desktop.showcaseBuildTab_Buttons(mode);
tabgroup.add(tab1);
tab2 = matlab.ui.internal.desktop.showcaseBuildTab_Selections();
tabgroup.add(tab2);
tab3 = matlab.ui.internal.desktop.showcaseBuildTab_EditValue();
tabgroup.add(tab3);
tab4 = matlab.ui.internal.desktop.showcaseBuildTab_Gallery();
tabgroup.add(tab4);
tab5 = matlab.ui.internal.desktop.showcaseBuildTab_Layout(mode);
tabgroup.add(tab5);
tabgroup.SelectedTab = tab1;
tabgroup.SelectedTabChangedFcn = @PropertyChangedCallback;            

% callback function
function PropertyChangedCallback(~, data)
if isempty(data.EventData.OldValue) && ~isempty(data.EventData.NewValue)
    fprintf('Property "%s" is changed from [] to "%s".\n',data.EventData.Property,data.EventData.NewValue.Title);
elseif ~isempty(data.EventData.OldValue) && isempty(data.EventData.NewValue)
    fprintf('Property "%s" is changed from "%s" to [].\n',data.EventData.Property,data.EventData.OldValue.Title);
elseif ~isempty(data.EventData.OldValue) && ~isempty(data.EventData.NewValue)
    fprintf('Property "%s" is changed from "%s" to "%s".\n',data.EventData.Property,data.EventData.OldValue.Title,data.EventData.NewValue.Title);
end
