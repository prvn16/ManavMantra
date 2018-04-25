function tab = showcaseBuildTab_Selections()
% Build the "Selection" tab in the toolstrip.

% Author(s): Rong Chen
% Copyright 2015 The MathWorks, Inc.
import matlab.ui.internal.toolstrip.*
% tab
tab = Tab('SELECTION');
tab.Tag = 'tab_selections';
%% checkbox section
section = tab.addSection(upper('CheckBox'));
section.Tag = 'sec_checkbox';
column = section.addColumn();
section.add(column);
control = CheckBox('This is a checkbox');
control.Description = 'this is a tooltip';
control.ValueChangedFcn = @PropertyChangedCallback;
column.add(control);
%% radio button section
group = matlab.ui.internal.toolstrip.ButtonGroup();
section = tab.addSection(upper('RadioButton'));
section.Tag = 'sec_radiobutton';
column = section.addColumn();
button1 = RadioButton(group, 'This is a radio button #1');
button1.Description = 'this is a tooltip';
button1.ValueChangedFcn = @PropertyChangedCallback;
column.add(button1);
button2 = RadioButton(group, 'This is a radio button #2');
button2.Description = 'this is a tooltip';
button2.ValueChangedFcn = @PropertyChangedCallback;
column.add(button2);
button1.Value = true;
%% combobox section
section = tab.addSection(upper('DropDown'));
section.Tag = 'sec_dropdown';
column1 = section.addColumn();
label = Label('Select a city:');
column1.add(label);
column2 = section.addColumn('Width',100);
control = DropDown({'L' 'London';'P' 'Paris';'B' 'Berlin';'M' 'Madrid';'R' 'Rome'});
control.Description = 'this is a tooltip';
control.Editable = true;
control.Value = 'B';
control.ValueChangedFcn = @PropertyChangedCallback;
column2.add(control);
%% listbox section
section = tab.addSection(upper('ListBox'));
section.Tag = 'sec_listbox';
column1 = section.addColumn();
label = Label('Select a city:');
column1.add(label);
column1.addEmptyControl();
column1.addEmptyControl();
column2 = section.addColumn('Width',100);
control = ListBox({'L' 'London';'P' 'Paris';'B' 'Berlin';'M' 'Madrid';'R' 'Rome'}, true);
control.Description = 'this is a tooltip';
control.Value = {'P';'M'};
control.ValueChangedFcn = @PropertyChangedCallback_Cell;
column2.add(control);

function PropertyChangedCallback(~, data)
fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',data.EventData.Property,num2str(data.EventData.OldValue),num2str(data.EventData.NewValue));

function PropertyChangedCallback_Cell(~, data)
fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',data.EventData.Property,[data.EventData.OldValue{:}],[data.EventData.NewValue{:}]);