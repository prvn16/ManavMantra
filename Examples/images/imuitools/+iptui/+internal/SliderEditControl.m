classdef SliderEditControl < handle
% SliderEditControl Handle class that excapsulates Slider and Edit field
% capability.

% Copyright 2014-2017 The MathWorks, Inc.

    properties(Access=public)
        SliderControl
        LabelControl
        EditControl
    end

    properties (Access=private)
        PropertyName
        CurrentValue
        MinValue
        MaxValue 
    end
    
    properties (Dependent)
        Minimum
        Maximum
    end

    events
        PropValueChanged
    end
    
    methods
        function this = SliderEditControl(labelName, minValue, maxValue, defaultValue)
            % Perform Initializations
            this.PropertyName = labelName;
            this.MinValue = minValue;
            this.MaxValue = maxValue;
            this.CurrentValue = defaultValue;

            % Create the label.
            this.LabelControl = matlab.ui.internal.toolstrip.Label(this.PropertyName);
            this.LabelControl.Tag = strcat(this.PropertyName, 'Label');

            % Set slider tick spacing and create label table.
            this.SliderControl = matlab.ui.internal.toolstrip.Slider([this.MinValue, this.MaxValue], this.CurrentValue);
%             this.SliderControl.MajorTickSpacing = ceil((this.MaxValue-this.MinValue)/20);
%             this.SliderControl.MinorTickSpacing = 1;
            this.SliderControl.Tag = strcat(this.PropertyName, 'Slider');

            addlistener(this.SliderControl,'ValueChanged',@(hobj,~)this.sliderEditControlCallback(hobj));

            % Create text field to enter slider.
            this.EditControl = matlab.ui.internal.toolstrip.EditField(num2str(this.CurrentValue));
            this.EditControl.Tag = strcat(this.PropertyName, 'Edit');
            addlistener(this.EditControl,'ValueChanged',@(hobj,~)this.sliderEditControlCallback(hobj));
        end
    end
    
    methods
        function min = get.Minimum(self)
            min = self.MinValue;
        end
        
        function max = get.Maximum(self)
            max = self.MaxValue;
        end
        
        function set.Minimum(self,min)
            self.MinValue = min;
            self.SliderControl.Minimum = min;
        end
        
        function set.Maximum(self,max)
            self.MaxValue = max;
            self.SliderControl.Maximum = max;
        end
    end

    methods(Access=private)
        function sliderEditControlCallback(this, obj)
            if isa(obj,'matlab.ui.internal.toolstrip.Slider')
                this.CurrentValue = obj.Value;
                this.EditControl.Value = num2str(this.CurrentValue);
            elseif isa(obj,'matlab.ui.internal.toolstrip.EditField')
                value = str2double(obj.Value);
                if isnan(value) || ~isreal(value)
                    % TODO: Do we need an unnecessary error message?
                    this.EditControl.Value = num2str(this.CurrentValue);
                    return;
                end
                
                % Valid value - continue.
                if value < this.MinValue
                    value = this.MinValue;
                elseif value > this.MaxValue
                    value = this.MaxValue;
                end      
                this.CurrentValue = value;
                this.EditControl.Value = num2str(value);
                this.SliderControl.Value = this.CurrentValue;
            end
            
            % Notify to listener to update camera object.
            notify(this, 'PropValueChanged');
        end
    end
end