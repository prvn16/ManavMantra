function tab = showcaseBuildTab_Layout(mode)
% Build the "Layout" tab in the toolstrip.

% Author(s): Rong Chen
% Copyright 2015 The MathWorks, Inc.
import matlab.ui.internal.toolstrip.*
%% tab
tab = Tab('LAYOUT');
tab.Tag = 'tab_layouts';
%% 1-2-3 section
% section
section = tab.addSection('3-2-1');
section.Tag = 'section_321';
% column 1
col = section.addColumn();
col.add(Button('Cut',Icon.COPY_16));
col.add(Button('Copy',Icon.CUT_16));
col.add(Button('Paste',Icon.PASTE_16));
% column 2
col = section.addColumn();
col.add(Button('Open',Icon.OPEN_16));
col.add(Button('Close',Icon.CLOSE_16));
% column 3
col = section.addColumn();
col.add(Button('New',Icon.NEW_24));
%% column span section
% section
section = tab.addSection('COLUMN SPAN');
section.Tag = 'section_columnspan';
% panel contains two columns
panel = Panel();
col1 = panel.addColumn('HorizontalAlignment','right');
col1.add(Label('X Label:'))
col1.add(Label('Y Label:'))
col2 = panel.addColumn('Width',100);
col2.add(EditField());
col2.add(EditField());
% column
col = section.addColumn('Width',200);
col.add(panel);
col.add(Slider([0 100],50));
%% empty row section
section = tab.addSection('EMPTY ROW');
section.Tag = 'section_emptyrow';
section.CollapsePriority = 10;
col = section.addColumn('HorizontalAlignment','right');
col.add(Label('Color:'));
col.add(Label('Object Size:'));
col.addEmptyControl();
col = section.addColumn('Width',100);
col.add(DropDown({'Red';'Green';'Blue'}));
col.add(DropDown({'Small';'Medium';'Large'}));
col.add(CheckBox('Wrap as gift'));
%% action sharing
% the remaining code are only available in JavaScript rendering
if strcmp(mode, 'javascript')
    section = tab.addSection('SHARING CONTROLS');
    % column: split button and listitem
    col = section.addColumn();
    btn = SplitButton('NEW',Icon.NEW_24);
    btn.Description = 'Create new document';
    btn.ButtonPushedFcn = @ActionPerformedCallback;
    col.add(btn);
    popup = PopupList();
    btn.Popup = popup;
    listitem = ListItem();
    popup.add(listitem);
    btn.shareWith(listitem);
    listitem.TextOverride = 'Script';
    listitem.IconOverride = Icon.OPEN_16;
    % column: checkbox and toggle button
    col = section.addColumn();
    btn = ToggleButton('Control1 is shared',Icon.CUT_16);
    btn.ValueChangedFcn = @PropertyChangedCallback;
    col.add(btn)
    chk = CheckBox();
    btn.shareWith(chk);
    col.add(chk);
    % column: radio buttons and toggle buttons
    grp = ButtonGroup();
    col1 = section.addColumn();
    btn1 = ToggleButton('Control2 is shared',Icon.COPY_16,grp);
    btn2 = ToggleButton('Control3 is shared',Icon.PASTE_16,grp);
    btn1.Value = true;
    btn1.ValueChangedFcn = @PropertyChangedCallback;
    btn2.ValueChangedFcn = @PropertyChangedCallback;
    col1.add(btn1);
    col1.add(btn2);
    col2 = section.addColumn();
    radio1 = RadioButton(grp);
    radio2 = RadioButton(grp);
    btn1.shareWith(radio1);
    btn2.shareWith(radio2);
    col2.add(radio1);
    col2.add(radio2);
end

%% callback functions
function ActionPerformedCallback(~, data)
if isempty(data.EventName)
    fprintf('Event "%s" occurs from the UI.\n', data.EventData.EventType);
else
    fprintf('Event "%s" occurs from the UI.\n', data.EventName);
end

function PropertyChangedCallback(~, data)
fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',data.EventData.Property,num2str(data.EventData.OldValue),num2str(data.EventData.NewValue));
