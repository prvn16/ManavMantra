classdef (Hidden) ComponentControllerFactory < appdesservices.internal.interfaces.controller.AbstractControllerFactory
    % COMPONENTCONTROLLERFACTORY This factory class should be used by each
    % component class to create a new instance of component's controller.
    %
    % The purpose of the factory is to:
    %
    % - Consolidate creation context
    % necessary to create the controllers.
    %
    % - Decouple the component class from the concrete controller
    % hierarchy.
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    
    methods
        
        function controller = createController(obj, component, parentController, proxyView)
            % CONTROLLER = CREATECONTROLLER(OBJ, COMPONENT,
            % PARENTCONTROLLER, PROXYVIEW)
            % 
            %
            % Creates a controller for the given component.
            %
            % Input:
            %
            %   component:              Handle to the component model object
            %
            %   parentController:       Handle to the component model's Parent's
            %                           Controller.  This should be empty if there
            %                           is no parent.
            %   
            %   proxyView:              Handle to the component's proxyView.
            %                           
            % Outputs:
            %
            %   controller:             Controller for this component
            % 
            % Todo: In the future of continous improving integration with
            % component framework, this factory probably can be removed.
            
            import matlab.ui.control.internal.controller.*;

            % Determine the controller based on the class of the component
            componentClassName = class(component);
            
            % No proxy view being passed in
            % For runtime, proxyView is alwasy be passed in as an empty [],
            % and so need for now. Probably can be got rid of if not passing
			% the empty as a proxy view argument
            if (nargin < 4)
                proxyView = [];
            end
            
            switch(componentClassName)
                % HMI Lamp --------------------------------------------

                case 'matlab.ui.control.Lamp'
                    controller = LampController(component, parentController, proxyView);

                % HMI - Gauges --------------------------------------------

                case 'matlab.ui.control.Gauge'
                    controller = GaugeComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.LinearGauge'
                    controller = GaugeComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.SemicircularGauge'
                    controller = GaugeComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.NinetyDegreeGauge'
                    controller = GaugeComponentController(component, parentController, proxyView);

                % HMI - Knobs --------------------------------------------

                case 'matlab.ui.control.Knob'
                    controller = InteractiveTickComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.DiscreteKnob'
                    controller = StateComponentController(component, parentController, proxyView);

                % HMI - Switches --------------------------------------------

                case 'matlab.ui.control.RockerSwitch'
                    controller = StateComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.ToggleSwitch'
                    controller = StateComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.Switch'
                    controller = StateComponentController(component, parentController, proxyView);

                % Standard Controls -----------------------------------

                case 'matlab.ui.control.Button'
                    controller = PushButtonController(component, parentController, proxyView);

                case 'matlab.ui.control.CheckBox'
                    controller = CheckBoxController(component, parentController, proxyView);

                case 'matlab.ui.control.EditField'
                    controller = EditFieldController(component, parentController, proxyView);

                case 'matlab.ui.control.TextArea'
                    controller = TextAreaController(component, parentController, proxyView);

                case 'matlab.ui.control.NumericEditField'
                    controller = NumberFieldController(component, parentController, proxyView);

                case 'matlab.ui.control.Spinner'
                    controller = SpinnerController(component, parentController, proxyView);

                case 'matlab.ui.control.Label'
                    controller = LabelController(component, parentController, proxyView);

                case 'matlab.ui.control.Slider'
                    controller = InteractiveTickComponentController(component, parentController, proxyView);

                case 'matlab.ui.control.DropDown'
                    controller = DropDownController(component, parentController, proxyView);                        

                case 'matlab.ui.control.RadioButton'
                    controller = RadioButtonController(component, parentController, proxyView);

                case 'matlab.ui.control.ToggleButton'
                    controller = ToggleButtonController(component, parentController, proxyView);

                case 'matlab.ui.control.StateButton'
                    controller = StateButtonController(component, parentController, proxyView);

                case 'matlab.ui.control.ListBox'
                    controller = ListBoxController(component, parentController, proxyView);
                
                case 'matlab.ui.container.Tree'
                    controller = matlab.ui.container.internal.controller.TreeController(component, parentController, proxyView);
                    
                case 'matlab.ui.container.TreeNode'
                    controller = matlab.ui.container.internal.controller.TreeNodeController(component, parentController, proxyView);
                
                case 'matlab.ui.control.DatePicker'
                    controller = matlab.ui.control.internal.controller.DatePickerController(component, parentController, proxyView);

                otherwise
                    % Use the default controller for components
                    controller = ComponentController(component, parentController, proxyView);
            end
        end
    end
end
