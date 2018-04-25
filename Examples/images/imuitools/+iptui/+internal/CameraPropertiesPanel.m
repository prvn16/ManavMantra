classdef CameraPropertiesPanel < handle
% CameraPropertiesPanel - Creates camera specific properties and associated
% tearaway.

% Copyright 2014-2017 The MathWorks, Inc.
    
    properties
        popup

        DevicePropObjects
    end
    
    properties(Access=private)
        CamObj
        ImagePreviewDisplay
    end

    methods
        function this = CameraPropertiesPanel(camObj, imPreviewDisplay)
            
            % Initialization
            this.CamObj = camObj;
            this.ImagePreviewDisplay = imPreviewDisplay;
            
            % Get the camera controller.
            camController = camObj.getCameraController;
            
            % Get all settable properties.
            props = set(camObj);
            propNames = fieldnames(props);
            sortedProps = sort(propNames(2:end));
            propNames(2:end) = sortedProps;
            
            % Have Mode properties listed before the actual value
            % properties.
            out = strfind(propNames, 'Mode');
            indices = find(~cellfun(@isempty,out));
            if ~isempty(indices)
               for idx = 1:length(indices)
                   modePropName = propNames{indices(idx)};
                   tempID = strfind(modePropName, 'Mode');
                   expectedPropName = modePropName(1:tempID-1);
                   if strcmpi(expectedPropName, propNames{indices(idx)-1})
                       propNames{indices(idx)-1} = modePropName;
                       propNames{indices(idx)} = expectedPropName;
                   end
               end
            end
            numProperties = length(propNames);
            horizontalSpacing = '7px,f:p,8px,f:p,8px,f:p,7px';
            verticalSpacing = '3px';
            for idx  = 1:numProperties
                verticalSpacing = strcat(verticalSpacing, ',f:p,8px');
            end
            panel = toolpack.component.TSPanel(...
                horizontalSpacing,...
                verticalSpacing);
            % Update the panel with right positions for all device
            % properties. 
            for idx =  1:numProperties
                if ~isempty(props.(propNames{idx}))
                    this.DevicePropObjects.(propNames{idx}) = iptui.internal.ComboBoxControl(propNames{idx}, props.(propNames{idx}){1}, camObj.(propNames{idx}));
                    addlistener(this.DevicePropObjects.(propNames{idx}), 'PropValueChanged', @(~,~)updateCameraObjectProps(this, propNames{idx}));
                    position = strcat('xy(4,',num2str(idx*2),')'); 
                    panel.add(this.DevicePropObjects.(propNames{idx}).ComboControl, position);
                else
                    range = camController.getPropertyRange(propNames{idx});
                    this.DevicePropObjects.(propNames{idx}) = iptui.internal.TSSliderEditControl(propNames{idx}, range(1), range(2), camObj.(propNames{idx}));
                    addlistener(this.DevicePropObjects.(propNames{idx}), 'PropValueChanged', @(~,~)updateCameraObjectProps(this, propNames{idx}));
                    position = strcat('xy(4,',num2str(idx*2),')'); 
                    panel.add(this.DevicePropObjects.(propNames{idx}).EditControl, position);
                    position = strcat('xy(6,',num2str(idx*2),')');
                    panel.add(this.DevicePropObjects.(propNames{idx}).SliderControl, position);
                    updateSliderAvailability(this, strcat(propNames{idx}, 'Mode'));
                end
                position = strcat('xy(2,',num2str(idx*2),')');
                panel.add(this.DevicePropObjects.(propNames{idx}).LabelControl, position);
            end
            
            this.popup = toolpack.component.TSTearOffPopup(panel);
        end
        
        function updateCameraObject(this, camObj, imPreviewDisplay)
            this.CamObj = camObj;
            this.ImagePreviewDisplay = imPreviewDisplay;
        end
    end
    
    methods(Access=private)
        function updateSliderAvailability(this, propName)
            % Update a slider/edit field based on combo box value.
            
            if strfind(propName, 'Resolution') % Resolution is special as preview needs update. 
                [width, height] = this.getResolution;
                replaceImage(this.ImagePreviewDisplay, width, height);
                return;
            end
            
            idx = strfind(propName, 'Mode');
            if isempty(idx)
                % Not a mode property. 
                return;
            end
            editPropName = propName(1:idx-1);
            try
                if isfield(this.DevicePropObjects, propName)
                    if strcmpi(this.DevicePropObjects.(propName).ComboControl.SelectedItem, 'auto')
                        this.DevicePropObjects.(editPropName).SliderControl.Enabled = false;
                        this.DevicePropObjects.(editPropName).EditControl.Enabled = false;
                    elseif strcmpi(this.DevicePropObjects.(propName).ComboControl.SelectedItem, 'manual')
                        this.DevicePropObjects.(editPropName).SliderControl.Enabled = true;
                        this.DevicePropObjects.(editPropName).EditControl.Enabled = true;                    
                    end
                end
            catch
                % Do nothing and continue.
            end
        end
        
        function updateCameraObjectProps(this, propName)
            propObject = this.DevicePropObjects.(propName);
            try
                if any(ismember(properties(propObject), 'EditControl'))
                    this.CamObj.(propName) = str2double(this.DevicePropObjects.(propName).EditControl.Text);
                else
                    this.CamObj.(propName) = this.DevicePropObjects.(propName).ComboControl.SelectedItem;
                    updateSliderAvailability(this, propName);
                end
            catch
                % Do nothing and continue.
            end
        end
        
        function [width, height] = getResolution(this)
            %TODO: Move this as a utility outside. 
            res = this.CamObj.Resolution;
            idx = strfind(res, 'x');
            width = str2double(res(1:idx-1));
            height = str2double(res(idx+1:end));
        end        
    end
end