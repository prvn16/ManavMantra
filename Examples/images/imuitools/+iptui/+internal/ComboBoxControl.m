classdef ComboBoxControl < handle
% ComboBoxControl Handle class that implements combo box functionality.

% Copyright 2014 The MathWorks, Inc.

    properties(Access=public)
        ComboControl
        LabelControl

    end

    properties(Access=private)
        PropertyName
        Selection
    end

    events
        PropValueChanged
    end

    methods
        function this = ComboBoxControl(labelName, entries, currentValue)
            %% Perform Initializations
            this.PropertyName = labelName;
            this.Selection = currentValue;

            % Create the label.
            this.LabelControl = toolpack.component.TSLabel(this.PropertyName);

            % Create the combobox.
            this.ComboControl = toolpack.component.TSComboBox(entries);
            this.ComboControl.Name = strcat(this.PropertyName, 'Combo');
            addlistener(this.ComboControl,'ActionPerformed',@(~,evt)this.updateComboBox(evt.Source));

        end
    end

    methods(Access=private)
        function updateComboBox(this, ~)
            notify(this, 'PropValueChanged');
        end
    end
end