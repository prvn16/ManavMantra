classdef (Hidden) IconAlignableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have the
    % 'IconAlignment' properties
    %
    % This class provides all implementation and storage for IconAlignment

    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Dependent)
        
        IconAlignment = 'left';
        
    end
      
    properties(Access = 'private')
        PrivateIconAlignment = 'left';        
    end
    
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
              
        function set.IconAlignment(obj, newValue)
            % Error Checking
            try
                newIconAlignment = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    newValue, ...
                    {'center', 'top', 'bottom', 'left', 'right'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidFiveStringEnum', ...
                    'IconAlignment', 'left', 'right', 'center', 'top', 'bottom');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidIconRelationToText';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateIconAlignment = newIconAlignment;
            
            % Update View
            markPropertiesDirty(obj, {'IconAlignment'});
        end
        
        function value = get.IconAlignment(obj)
            value = obj.PrivateIconAlignment;
        end
    end
end
