classdef ValidationUtility
    %INPUTVALIDATORUTILITY Handles the validation
    % Provides helper functions to validate the widget values on the UI
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(Constant)
        ConstPropMap = ["absToleranceTextField", "AbsTol";
            "relToleranceTextField", "RelTol";
            "hardwareSettingWL", "WordLengths"];
        
        DesignInfoMap = [FuncApproxUI.Utils.lookuptableMessage('setupPaneSpecTableInputDTHeader'), "InputTypes";
            FuncApproxUI.Utils.lookuptableMessage('setupPaneSpecTableDesignMinHeader'), "InputLowerBounds";
            FuncApproxUI.Utils.lookuptableMessage('setupPaneSpecTableDesignMaxHeader'), "InputUpperBounds";
            "outputTypeTextField", "OutputType"];
    end
    
    methods(Static)
        
        function [validationObject, nameMap] = getValidationUtils(validationType)
            % Factory to get the validation object and parameter name map
            validationObject = {};
            nameMap = [];
            switch validationType
                case "Problem"
                    validationObject = FunctionApproximation.Problem();
                    nameMap = FuncApproxUI.Utils.ValidationUtility.DesignInfoMap;
                case "Options"
                    validationObject = FunctionApproximation.Options();
                    nameMap = FuncApproxUI.Utils.ValidationUtility.ConstPropMap;
                    % No other possibility
            end
        end
        
        function isValid = validateParam(validationType, paramName, value)
            [validationObject, constMap] = FuncApproxUI.Utils.ValidationUtility.getValidationUtils(validationType);
            
            index = constMap == paramName;
            inputName = constMap(index, 2);
            
            try
                parsedValue = FunctionApproximation.internal.Utils.parseCharValue(value);
                validationObject.(inputName) = parsedValue;
                isValid = true;
            catch
                isValid = false;
            end
        end
    end
end

