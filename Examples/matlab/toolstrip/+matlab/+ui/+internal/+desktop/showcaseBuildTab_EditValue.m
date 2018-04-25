function tab = showcaseBuildTab_EditValue()
% Build the "Values" tab in the toolstrip.

% Author(s): Rong Chen
% Copyright 2015 The MathWorks, Inc.
import matlab.ui.internal.toolstrip.*
%% tab
tab = Tab('VALUES');
tab.Tag = 'tab_editvalue';
%% edit field section
section = tab.addSection(upper('EditField'));
section.Tag = 'sec_editfield';
column = section.addColumn('Width',100);
control = EditField('type here');
control.Description = 'this is a tooltip';
control.ValueChangedFcn = @PropertyChangedCallback;
addlistener(control,'FocusLost',@(x,y) EventCallback(x,y,'FocusLost'));
addlistener(control,'FocusGained',@(x,y) EventCallback(x,y,'FocusGained'));
column.add(control);
%% text area section
section = tab.addSection(upper('TextArea'));
section.Tag = 'sec_textarea';
column = section.addColumn('Width',100);
control = TextArea('type here');
control.Description = 'this is a tooltip';
control.ValueChangedFcn = @PropertyChangedCallback;
addlistener(control,'FocusLost',@(x,y) EventCallback(x,y,'FocusLost'));
addlistener(control,'FocusGained',@(x,y) EventCallback(x,y,'FocusGained'));
column.add(control);
%% slider section
section = tab.addSection(upper('Slider'));
section.Tag = 'sec_slider';
column = section.addColumn('Width',300);
control = Slider([0 100],50);
control.Description = 'this is a tooltip';
control.Labels = {'a' 0;'b' 10;'c' 30;'d' 80;'e' 100};
control.Ticks = 21;
control.ValueChangedFcn = @ValueChangedCallback;
addlistener(control,'ValueChanged',@ValueChangedCallback);
addlistener(control,'ValueChanging',@ValueChangingCallback);
column.add(control);
%% spinner section
section = tab.addSection(upper('Spinner'));
section.Tag = 'sec_spinner';
column = section.addColumn('Width',100);
control = Spinner([0 100],50);
control.Description = 'this is a tooltip';
control.StepSize = 2;
control.ValueChangedFcn = @ValueChangedCallback;
addlistener(control,'ValueChanged',@ValueChangedCallback);
addlistener(control,'ValueChanging',@ValueChangingCallback);
column.add(control);

function PropertyChangedCallback(~, data)
fprintf('Property "%s" is changed in the UI.  Old value is "%s".  New value is "%s".\n',data.EventData.Property,num2str(data.EventData.OldValue),num2str(data.EventData.NewValue));

function EventCallback(~, data, type)
fprintf('Event "%s" is fired from the UI.  Attached Value is "%s".\n', type, data.EventData.Value);

function ValueChangedCallback(~, data)
fprintf('Property "Value" is changed in the UI.  New value is "%s".\n',num2str(data.EventData.Value));

function ValueChangingCallback(~, data)
fprintf('Event "ValueChanging" is fired from the UI.  New walue is "%s".\n', num2str(data.EventData.NewValue));
