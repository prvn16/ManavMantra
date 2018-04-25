function tab = showcaseBuildTab_Buttons(mode)
% Build the "Buttons" tab in the toolstrip.

% Author(s): Rong Chen
% Copyright 2015 The MathWorks, Inc.
import matlab.ui.internal.toolstrip.*
%% tab
tab = Tab('BUTTONS');
tab.Tag = 'tab_buttons';
%% push button section
section = tab.addSection(upper('Push Button'));
section.Tag = 'sec_push';
column1 = section.addColumn();
button = Button('Vertical',Icon.NEW_24); % built-in
button.Tag = 'pushV';
button.Description = 'this is a tooltip';
button.ButtonPushedFcn = @ActionPerformedCallback;
column1.add(button);
column2 = section.addColumn();
button = Button('Horizontal',Icon(fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','New_16.png'))); % image file
button.Tag = 'pushH';
button.Description = 'this is a tooltip';
addlistener(button, 'ButtonPushed', @ActionPerformedCallback);
column2.addEmptyControl();
column2.add(button);
column2.addEmptyControl();
%% drop down button section
section = tab.addSection(upper('Drop Down Button'));
section.Tag = 'sec_dropdown';
column1 = section.addColumn();
button = DropDownButton('Vertical',Icon.OPEN_24); % built-in
button.Tag = 'dropdownV';
button.Description = 'this is a tooltip';
button.Popup = buildStaticPopupList_SmallIcon(mode);
column1.add(button);
column2 = section.addColumn();
imagefile = fullfile(matlabroot,'toolbox','shared','controllib','general','resources','toolstrip_icons','Open_16.png');
button = DropDownButton('Horizontal',Icon(javaObjectEDT('javax.swing.ImageIcon',imagefile))); % ImageIcon from file
button.Tag = 'dropdownH';
button.Description = 'this is a tooltip';
button.Popup = buildStaticPopupList_LargeIcon();
column2.addEmptyControl();
column2.add(button);
column2.addEmptyControl();
%% split button section
section = tab.addSection(upper('Split Button'));
section.Tag = 'sec_split';
column1 = section.addColumn();
button = SplitButton('Vertical',Icon.ADD_24);
button.Tag = 'splitV';
button.Description = 'this is a tooltip';
button.ButtonPushedFcn = @ActionPerformedCallback;
button.DynamicPopupFcn = @(x,y) buildDynamicPopupList_SmallIcon(mode);
column1.add(button);
column2 = section.addColumn();
button = SplitButton('Horizontal',Icon.ADD_16);
button.Tag = 'splitH';
button.Description = 'this is a tooltip';
addlistener(button, 'ButtonPushed', @ActionPerformedCallback);
button.DynamicPopupFcn = @(x,y) buildDynamicPopupList_LargeIcon();
column2.addEmptyControl();
column2.add(button);
column2.addEmptyControl();
%% toggle button section (individual)
section = tab.addSection(upper('Toggle Button'));
section.Tag = 'sec_toggle';
column1 = section.addColumn();
button = ToggleButton('Vertical',Icon.PLAY_24);
button.Tag = 'toggleV';
button.Description = 'this is a tooltip';
button.ValueChangedFcn = @PropertyChangedCallback;
column1.add(button);
column2 = section.addColumn();
button = ToggleButton('Horizontal',Icon.PLAY_16);
button.Tag = 'toggleH';
button.Description = 'this is a tooltip';
addlistener(button, 'ValueChanged', @PropertyChangedCallback);
column2.addEmptyControl();
column2.add(button);
column2.addEmptyControl();
%% toggle button section (group)
group = matlab.ui.internal.toolstrip.ButtonGroup;
section = tab.addSection(upper('Toggle Button Group'));
section.Tag = 'sec_togglegroup';
column1 = section.addColumn();
RGB = ones(24,24,3,'uint8');
RGB(:,:,1) = uint8(255);
RGB(:,:,2) = uint8(0);
RGB(:,:,3) = uint8(0);
button1 = ToggleButton('Red',Icon(javaObjectEDT('javax.swing.ImageIcon',im2java(RGB))),group);
button1.Tag = 'toggle1';
button1.Description = 'this is a tooltip';
button1.ValueChangedFcn = @PropertyChangedCallback;
column1.add(button1);
column2 = section.addColumn();
RGB = ones(24,24,3,'uint8');
RGB(:,:,1) = uint8(0);
RGB(:,:,2) = uint8(255);
RGB(:,:,3) = uint8(0);
button2 = ToggleButton('Green',Icon(javaObjectEDT('javax.swing.ImageIcon',im2java(RGB))),group);
button2.Tag = 'toggle2';
button2.Description = 'this is a tooltip';
button2.ValueChangedFcn = @PropertyChangedCallback;
column2.add(button2);
column3 = section.addColumn();
RGB = ones(24,24,3,'uint8');
RGB(:,:,1) = uint8(0);
RGB(:,:,2) = uint8(0);
RGB(:,:,3) = uint8(255);
button3 = ToggleButton('Blue',Icon(javaObjectEDT('javax.swing.ImageIcon',im2java(RGB))),group);
button3.Tag = 'toggle3';
button3.Description = 'this is a tooltip';
button3.ValueChangedFcn = @PropertyChangedCallback;
column3.add(button3);
button2.Value = true; % select the 2nd button initially

function popup = buildStaticPopupList_SmallIcon(mode)
import matlab.ui.internal.toolstrip.*
% popup list
popup = PopupList();
% list header
header = PopupListHeader('List Items');
popup.add(header);
% list item
item = ListItem('This is item 1', Icon.MATLAB_16);
item.Description = 'this is a tooltip';
item.ShowDescription = false;
item.ItemPushedFcn = @ActionPerformedCallback;
popup.add(item);
% list item
item = ListItem('This is item 2', Icon.SIMULINK_16);
item.Description = 'this is a tooltip';
item.ShowDescription = false;
addlistener(item, 'ItemPushed', @ActionPerformedCallback);
popup.add(item);
% list header
header = PopupListHeader('List Item with Checkboxes');
popup.add(header);
% list item with checkbox
item = ListItemWithCheckBox('This is item 3', true);
item.Description = 'this is a tooltip';
item.ShowDescription = false;
item.ValueChangedFcn = @PropertyChangedCallback;
popup.add(item);
% list item with popup
item = ListItemWithPopup('This is item 4',Icon.ADD_16);
item.Description = 'this is a tooltip';
item.ShowDescription = false;
popup.add(item);
% sub popup
sub_popup = PopupList();
item.Popup = sub_popup;
% sub list item
sub_item1 = ListItem('This is sub item 1', Icon.MATLAB_16);
sub_item1.Description = 'this is a tooltip';
sub_item1.ShowDescription = false;
sub_item1.ItemPushedFcn = @ActionPerformedCallback;
sub_popup.add(sub_item1);
% sub list item
sub_item2 = ListItem('This is sub item 2', Icon.SIMULINK_16);
sub_item2.Description = 'this is a tooltip';
sub_item2.ShowDescription = false;
sub_item2.ItemPushedFcn = @ActionPerformedCallback;
sub_popup.add(sub_item2);
% the remaining controls are only available in JavaScript rendering
% ListItemWithEditField, ListItemWithRadioButton, PopupListPanel, Separator
if strcmp(mode, 'javascript')
    % separator
    sub_popup.addSeparator();
    % popup list panel
    panel = PopupListPanel('MaxHeight',100);
    header1 = PopupListHeader('This is another header');
    panel.add(header1);
    sub_item3 = ListItem('This is sub item 3');
    sub_item3.ItemPushedFcn = @ActionPerformedCallback;
    panel.add(sub_item3);
    % list item with edit field
    sub_item4 = ListItemWithEditField('This is sub item 4');
    sub_item4.ValueChangedFcn = @PropertyChangedCallback;
    panel.add(sub_item4);
    grp = ButtonGroup();
    sub_item5 = ListItemWithRadioButton(grp, 'This is sub item 5');
    sub_item5.ValueChangedFcn = @PropertyChangedCallback;
    panel.add(sub_item5);
    % list item with radio button
    sub_item6 = ListItemWithRadioButton(grp, 'This is sub item 6');
    sub_item6.ValueChangedFcn = @PropertyChangedCallback;
    panel.add(sub_item6);
    sub_popup.add(panel);
end

function popup = buildStaticPopupList_LargeIcon()
import matlab.ui.internal.toolstrip.*
% popup list
popup = PopupList();
% list header
header = PopupListHeader('List Items');
popup.add(header);
% list item
item = ListItem('This is item 1', Icon.MATLAB_24);
item.Description = 'This is a tooltip';
item.ItemPushedFcn = @ActionPerformedCallback;
popup.add(item);
% list item
item = ListItem('This is item 2', Icon.SIMULINK_24);
item.Description = 'This is a tooltip';
addlistener(item, 'ItemPushed', @ActionPerformedCallback);
popup.add(item);
% list header
header = PopupListHeader('List Item with Checkboxes');
popup.add(header);
% list item with checkbox
item = ListItemWithCheckBox('This is item 3', false);
item.Description = 'This is a tooltip';
addlistener(item, 'ValueChanged', @PropertyChangedCallback);
popup.add(item);
% list item with popup
item = ListItemWithPopup('This is item 4',Icon.ADD_24);
item.Description = 'this is a tooltip';
popup.add(item);
% sub popup
sub_popup = PopupList();
item.Popup = sub_popup;
% sub list item
sub_item1 = ListItem('This is sub item 1', Icon.MATLAB_24);
sub_item1.Description = 'this is a tooltip';
sub_item1.ItemPushedFcn = @ActionPerformedCallback;
sub_popup.add(sub_item1);
% sub list item
sub_item2 = ListItem('This is sub item 2', Icon.SIMULINK_24);
sub_item2.Description = 'this is a tooltip';
sub_item2.ItemPushedFcn = @ActionPerformedCallback;
sub_popup.add(sub_item2);

function popup = buildDynamicPopupList_SmallIcon(mode)
import matlab.ui.internal.toolstrip.*
popup = PopupList();
item = ListItem('This popup list is dynamic!',Icon.MATLAB_16);
item.Description = 'This is a tooltip';
item.ShowDescription = false;
item.ItemPushedFcn = @ActionPerformedCallback;
popup.add(item);
item = ListItem(['Random Number: ',num2str(rand)],Icon.SIMULINK_16);
item.Description = 'This is a tooltip';
item.ShowDescription = false;
item.ItemPushedFcn = @ActionPerformedCallback;
popup.add(item);
item = ListItemWithPopup('this item has a sub popup list',Icon.ADD_16);
item.Description = 'This is a tooltip';
item.ShowDescription = false;
subpopup = PopupList();
item.Popup = subpopup;
sub_item = ListItem('this popup list is static.',Icon.MATLAB_16);
sub_item.Description = 'This is a tooltip';
sub_item.ShowDescription = false;
sub_item.ItemPushedFcn = @ActionPerformedCallback;
subpopup.add(sub_item);
sub_item = ListItem('Simulink',Icon.SIMULINK_16);
sub_item.Description = 'This is a tooltip';
sub_item.ShowDescription = false;
sub_item.ItemPushedFcn = @ActionPerformedCallback;
subpopup.add(sub_item);
popup.add(item);

function popup = buildDynamicPopupList_LargeIcon()
import matlab.ui.internal.toolstrip.*
popup = PopupList();
item = ListItem('This popup list is dynamic!',Icon.MATLAB_24);
item.Description = 'This is a tooltip';
item.ItemPushedFcn = @ActionPerformedCallback;
popup.add(item);
item = ListItem(['Random Number: ',num2str(rand)],Icon.SIMULINK_24);
item.Description = 'This is a tooltip';
item.ItemPushedFcn = @ActionPerformedCallback;
popup.add(item);
item = ListItemWithPopup('this item has a sub popup list',Icon.ADD_24);
item.Description = 'This is a tooltip';
subpopup = PopupList();
item.Popup = subpopup;
sub_item = ListItem('this popup list is static.',Icon.MATLAB_24);
sub_item.Description = 'This is a tooltip';
sub_item.ItemPushedFcn = @ActionPerformedCallback;
subpopup.add(sub_item);
sub_item = ListItem('Simulink',Icon.SIMULINK_24);
sub_item.Description = 'This is a tooltip';
sub_item.ItemPushedFcn = @ActionPerformedCallback;
subpopup.add(sub_item);
popup.add(item);

%% callback functions
function ActionPerformedCallback(~, data)
if isempty(data.EventName)
    fprintf('Event "%s" occurs from the UI.\n', data.EventData.EventType);
else
    fprintf('Event "%s" occurs from the UI.\n', data.EventName);
end

function PropertyChangedCallback(~, data)
fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',data.EventData.Property,num2str(data.EventData.OldValue),num2str(data.EventData.NewValue));

