classdef (Hidden) VerticallyAlignableComponent < appdesservices.internal.interfaces.model.AbstractModelMixin
    % This undocumented class may be removed in a future release.
    
    % This is a mixin parent class for all visual components that have an
    % 'VerticalAlignment' property
    %
    % This class provides all implementation and storage for 'VerticalAlignment'
    
    % Copyright 2012-2015 The MathWorks, Inc.
    
    properties(Dependent)
        VerticalAlignment = 'center';
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
        
        PrivateVerticalAlignment = 'center';
    end
    
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        function set.VerticalAlignment(obj, newValue)
            % Error Checking
            try
                newVerticalAlignment = matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString(...
                    obj, ...
                    newValue, ...
                    {'top', 'center', 'bottom'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidThreeStringEnum', ...
                    'VerticalAlignment', 'top', 'center', 'bottom');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidVerticalAlignment';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateVerticalAlignment = newVerticalAlignment;
            
            % Update View
            markPropertiesDirty(obj, {'VerticalAlignment'});
        end
        
        function value = get.VerticalAlignment(obj)
            value = obj.PrivateVerticalAlignment;
        end
    end
end
