classdef GridLayoutConstraints < matlab.ui.control.internal.model.LayoutConstraints
    % This undocumented class may be removed in a future release.
    %
    % This class is the layout constraints class that should be used when
    % the component is parented to a grid layout container.
    %
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Row = -1;
        Column = -1;
    end
    
    methods
        function set.Row(obj, value)
            
            % Validation
            try                
                value = matlab.ui.control.internal.model.PropertyHandling.validateScalarOrIncreasingArrayOf2(...
                    value);
            
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidScalarOrIncreasingArrayOf2', ...
                    'Row');
                
                % MnemonicField is last section of error id
                mnemonicField = 'InvalidGridRow';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            obj.Row = value;
        end
        
        function set.Column(obj, value)
            
            % Validation
            try                
                value = matlab.ui.control.internal.model.PropertyHandling.validateScalarOrIncreasingArrayOf2(...
                    value);
            
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidScalarOrIncreasingArrayOf2', ...
                    'Column');
                
                % MnemonicField is last section of error id
                mnemonicField = 'InvalidGridColumn';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            obj.Column = value;
        end
    end
    
    
end

