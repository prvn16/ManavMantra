classdef (Hidden) MultilineTextComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have a
    % 'Text' property which supports a multi - line text specification.
    %
    % This class provides all implementation and storage for 'Text'
    
    % Copyright 2012-2015 The MathWorks, Inc.
    
    properties(Dependent)
        Text = '';
    end
    
    properties(Access = 'private')
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control for each property
        %
        % - circumvent the setter, because sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateText = '';
    end
            
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.Text(obj, newValue)
            % Error Checking
            try
                newValue = matlab.ui.control.internal.model.PropertyHandling.validateMultilineText(newValue);
            catch %#ok<CTCH>
                messageObj = message('MATLAB:ui:components:invalidMultilineTextValue', ...
                    'Text');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidMultilineTextValue';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateText = newValue;
            
            % Update View
            markPropertiesDirty(obj, {'Text'});
        end
        
        function value = get.Text(obj)
            value = obj.PrivateText;
        end
    end
end
